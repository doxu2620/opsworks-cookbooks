include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'java'
    Chef::Log.debug("Skipping deploy::java-stop application #{application} as it is not a Java app")
    next
  end

  service 'tomcat' do
  service_name node['opsworks_java']['tomcat']['old_service_name']

  case node[:platform_family]
  when 'debian'
    supports :restart => true, :reload => false, :status => true
  when 'rhel'
    supports :restart => true, :reload => true, :status => true
  end

  action :nothing
  end
  
  execute "trigger #{node['opsworks_java']['java_app_server']} service stop" do
    command '/bin/true'
    notifies :stop, "service[#{node['opsworks_java']['java_app_server']}]"
  end

  include_recipe 'apache2::service'
  
  service 'apache2' do
    action :stop
  end
end

