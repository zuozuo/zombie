##这个库设计目的在于实现 micro service 之间的数据交换和模型相互映射，并且在 api 定义改变的时候自动更新客户端的映射模型。 运行依赖于 Grape， RestClient 和 ActiveRecord。

###使用方法：
####配置服务端

#####Gemfile 里加入
    gem 'service_gem', :git => 'git@github.com:rongchang/service_gem.git'

#####并且在相应的 grape 文件里
    include ZombieModel

#####然后指定服务端原模型的 class
    source_model :Courier

#####定义反射模型支持的 instance variables（既可以是 source model 的变量， 也可以是source model 里可以返回值的方法）：
    model_attrs :id, :realname

#####如果需要取 source model 的所有变量，可以使用关键字
    model_attrs :_all_attrs

#####如果使用了 :_all_attrs，并且想屏蔽部分变量，可以使用下面的方法定义变量黑名单
    model_attr_black_list :password
####配置客户端：

    在 config/initialize目录下新建 zombie_conf.rb 并且配置下列选项

    Zombie.host = "http://127.0.0.1:80"                                     # 路由服务器地址

    ZombieModel.service_host = "http://127.0.0.1:3000"                      # 服务端本机地址和端口
    ZombieModel.service_name = "order_server"                               # 服务端本机地址和端口
    ZombieModel.service_root_path = "/api"                                  # 服务端接口根路径
    ZombieModel.router_conf_path = "http://127.0.0.1:12121/set_model_path"  # 路由服务器动态配置路径

####定义可以直接通过 source_model 内部方法处理的接口

#####类方法接口（主要用于查找符合条件的实例）
    model_class_methods_in_get
    model_class_methods_in_post

#####active record 内支持的链式查找方法（比如 where， order 或 paginate 等）
    chain_methods :where, :limit

#####实例方法接口（用于单个实例的方法触发）
    model_methods_in_get
    model_methods_in_post

#####会引起客户端实例内容变化的方法（比如save， update_attributes 等操作）
    self_renew_methods_model :save , :update_attributes


####定义通过接口封装过的方法（需要自己定义 grape 的路由和方法实现）

#####接口封装过的类方法：
    api_class_methods_in_get :keys
    api_class_methods_in_post

#####接口封装过的实例方法：
    api_methods_in_get
    api_methods_in_post

#####会引起客户端实例内容变化的方法
    self_renew_methods_api
