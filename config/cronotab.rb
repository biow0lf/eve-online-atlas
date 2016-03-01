require 'rake'
CrestApiContest::Application.load_tasks

class Test
  def perform
    Rake::Task['update:test'].invoke
  end
end

Crono.perform(Test).every 10.seconds