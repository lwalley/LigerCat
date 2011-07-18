module ActionView
  module Helpers
    module AssetTagHelper
      require 'jsminlib'
      require 'css_packer'
      
      def get_file_contents(filename)
        contents = File.read(filename)
        if filename =~ /\.js$/
          JSMin.minify(contents)
        elsif filename =~ /\.css$/
          Rainpress.compress(contents)
        end
      end

      def join_asset_file_contents(paths)
        paths.collect { |path|
          get_file_contents(File.join(ASSETS_DIR, path.split("?").first)) }.join("\n\n")
      end
      
    end
  end
end