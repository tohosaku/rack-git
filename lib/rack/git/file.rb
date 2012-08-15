require 'time'
require 'rack/utils'
require 'rack/mime'
require 'grit'

module Rack
  module Git
    class File
      attr_accessor :root
      attr_accessor :path

      alias :to_path :path

      def initialize(root)
        @root = root
        @repo = Grit::Repo.new(@root)
      end

      def call(env)
        dup._call(env)
      end

      F = ::File

      def _call(env)
        @branch_name = env['PATH_PREFIX'].sub(/^\//,"") || "master"
        @path_info = Rack::Utils.unescape(env["PATH_INFO"]).sub(/^\//,"")
        return forbidden  if @path_info.include? ".."

        begin
          serving
        rescue SystemCallError
          not_found
        end
      end

      def forbidden
        body = "Forbidden\n"
        [403, {"Content-Type" => "text/plain",
            "Content-Length" => body.size.to_s,
            "X-Cascade" => "pass"},
          [body]]
      end

      # NOTE:
      #   We check via File::size? whether this file provides size info
      #   via stat (e.g. /proc files often don't), otherwise we have to
      #   figure it out by reading the whole file into memory. And while
      #   we're at it we also use this as body then.

      def serving
        history       = @repo.log(@branch_name, @path_info, :max_count => 1, :skip => 0)
        blob          = history[0].tree / @path_info

        body          = blob.data
        last_modified = history[0].authored_date
        size          = blob.size

        [200, {
            "Last-Modified"  => last_modified.httpdate,
            "Content-Type"   => Rack::Mime.mime_type(F.extname(@path_info), 'text/plain'),
            "Content-Length" => size.to_s
          }, body]
      end

      def not_found
        body = "File not found: #{@path_info}\n"
        [404, {"Content-Type" => "text/plain",
            "Content-Length" => body.size.to_s,
            "X-Cascade" => "pass"},
          [body]]
      end

      def each
        body = @repo.tree(@branch_name).contents.select{|c| c.name == @path_info}[0].data
        StringIO.new(body, "rb") do |file|
          while part = file.read(8192)
            yield part
          end
        end
      end
    end
  end
end
