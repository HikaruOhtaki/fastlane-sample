module Fastlane
  module Actions
    class SampleAction < Action

      def self.run(params)
        UI.message("LOG")
        UI.message(Dir.glob("~/Applications"))
        UI.message(Dir.glob("~/"))
        UI.message("DEVELOPER_DIR")
      end

      def self.description
        "意味が無いactionであります"
      end

      def self.available_options
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
