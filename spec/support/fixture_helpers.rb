module Support
  module FixtureHelpers
    def file_fixture_base_path
      File.expand_path('../files', __dir__)
    end

    def file_fixture_filename(path)
      File.join(file_fixture_base_path, path)
    end

    def file_fixture_contents(path)
      File.read(file_fixture_filename(path))
    end
  end
end