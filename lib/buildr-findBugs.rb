# A quick extension to use Findbugs:

module Buildr
  module FindBugs
    include Extension

    class FindBugsTask < Rake::Task

      attr_reader :project
      
      attr_writer :sourcePath, :auxAnalyzePath, :auxClasspath, :jvmargs, :report

      def initialize(*args) #:nodoc:
        super
        enhance do
          raise "Cannot run Findbugs, FINDBUGS_HOME undefined" unless defined? ENV['FINDBUGS_HOME']
          mkpath File.dirname(report) #otherwise Findbugs can't create the file
          
          Buildr.ant('findBugs') do |ant|
            refid = "#{project.name}-auxClasspath"
            artifacts = [Buildr::artifact("com.google.code.findbugs:findbugs-ant:jar:1.3.9")]
            artifacts.each {|lib| lib.invoke}
            # We use a huge classpath.
            ant.path :id => refid do
              [[auxClasspath] + artifacts].flatten.each do |elt|
                ant.pathelement :location => elt
              end
            end
            
            ant.taskdef :name=>'findBugs',
                  :classname=>'edu.umd.cs.findbugs.anttask.FindBugsTask', :classpathref => refid
            ant.findBugs :output => "xml", :outputFile => report, :home => ENV['FINDBUGS_HOME'], :jvmargs => jvmargs do
              ant.sourcePath(:path => sourcePath)
              ant.auxAnalyzePath :path => auxAnalyzePath
              ant.auxClasspath :refid => refid
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
        @auxClasspath || [project.compile.dependencies]
      end
      
      def jvmargs
        @jvmargs || "-Xmx512m"
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

    def findBugs(*deps, &block)
      task('findBugs').enhance deps, &block
    end
  end
end

class Buildr::Project
  include Buildr::FindBugs
end