# A quick extension to use Findbugs:

module Buildr
  module FindBugs
    include Extension
    VERSION = "1.3.9"

    class << self
      def version
        Buildr.settings.build['findbugs'] || VERSION
      end
    end

    REQUIRES = ["com.google.code.findbugs:findbugs-ant:jar:#{version}"]

    class << self
      def requires
        @requires ||= Buildr.transitive(REQUIRES).each(& :invoke).map(& :to_s)
      end
    end

    class FindBugsTask < Rake::Task

      attr_reader :project

      attr_writer :sourcePath, :auxAnalyzePath, :auxClasspath, :jvmargs, :report, :excludeFilter

      def initialize(* args) #:nodoc:
        super
        enhance([:compile]) do
          mkpath File.dirname(report) #otherwise Findbugs can't create the file

          Buildr.ant('findBugs') do |ant|
            antClasspath = FindBugs.requires.join(File::PATH_SEPARATOR)
            excludeFilterFile = File.expand_path(excludeFilter)

            ant.taskdef :name=>'findBugs',
                        :classname=>'edu.umd.cs.findbugs.anttask.FindBugsTask',
                        :classpath => antClasspath
            ant.findBugs :output => "xml", :outputFile => report, :classpath => antClasspath, :pluginList => '', :jvmargs => jvmargs, :excludeFilter => excludeFilterFile do
              ant.sourcePath :path => sourcePath
              ant.auxAnalyzePath :path => auxAnalyzePath
              ant.auxClasspath { |aux| auxClasspath.each { |dep| aux.pathelement :location => dep } } unless auxClasspath.empty?
            end

          end

        end
      end

      def report
        @report || project.path_to(:reports, "findbugs.xml")
      end

      def sourcePath
        @sourcePath || project.compile.sources.select { |source| File.directory?(source) }.join(File::PATH_SEPARATOR)
      end

      def auxAnalyzePath
        @auxAnalyzePath || project.compile.target
      end

      def auxClasspath
        @auxClasspath || project.compile.dependencies
      end

      def jvmargs
        @jvmargs || "-Xmx512m"
      end

      def excludeFilter
        @excludeFilter || project.path_to("exclude_filter.xml")
      end

      # :call-seq:
      #   with(options) => self
      #
      # Passes options to the task and returns self.
      #
      def with(options)
        options.each do |key, value|
          begin
            send "#{key}=", value
          rescue NoMethodError
            raise ArgumentError, "#{self.class.name} does not support the option #{key}"
          end
        end
        self
      end

      private

      def associate_with(project)
        @project = project
      end


    end

    first_time do
      desc 'Run Findbugs'
      Project.local_task('findBugs') { |name| "Run Findbugs on #{name}" }
    end

    before_define do |project|
      task = FindBugsTask.define_task('findBugs')
      task.send :associate_with, project
      project.recursive_task('findBugs')
    end

    after_define do |project|
      project.clean do
        rm_rf project.path_to(:reports, "findbugs.xml")
      end
    end

    def findBugs(* deps, & block)
      task('findBugs').enhance deps, & block
    end
  end
end

class Buildr::Project
  include Buildr::FindBugs
end

