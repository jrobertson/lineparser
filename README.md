# Introducing the Lineparser gem

    require 'lineparser'

    lines =<<LINES
    resources: posts
    # winning
    #
    post
      model
        Post
          orange 123
          fff
    comments
      model
        Comment
          orange 576
          ggg
    LINES

    patterns = [
      [:root, 'resources: :resources', :resources],
      [:root, ':resource', :resource],
        [:resource, 'model', :model],
          [:model, ':class_name', :model_class],
            [:model_class, /orange (\w+)/, :model_class_attribute],
      [:all, /#/]
    ]

    lp = LineParser.new patterns
    r = lp.parse lines

output observed:

<pre>
[
  [:root, {":resources"=>"posts"}, ["resources: posts"], nil], 
  [:all, {:captures=>[]}, ["# winning"], nil], 
  [:all, {:captures=>[]}, ["#"], nil], 
  [:root, {":resource"=>"post"}, ["post", ["model", ["Post", ["orange 123"], ["fff"]]]],
    [[:resource, {}, ["model", ["Post", ["orange 123"], ["fff"]]],
      [[:model, {":class_name"=>"Post"}, ["Post", ["orange 123"], ["fff"]], 
        [[:model_class, {:captures=>["123"]}, ["orange 123"], nil]]
      ]]
    ]]
  ], 
  [:root, {":resource"=>"comments"}, ["comments", ["model", ["Comment", ["orange 576"], ["ggg"]]]],
    [[:resource, {}, ["model", ["Comment", ["orange 576"], ["ggg"]]], 
      [[:model, {":class_name"=>"Comment"}, ["Comment", ["orange 576"], ["ggg"]],
        [[:model_class, {:captures=>["576"]}, ["orange 576"], nil]]
      ]]
    ]]
  ]
] 
</pre>

# Creating an XML doc from a configuration file using lineparser

Lineparser is a gem I recently wrote to parse configuration files that I'm planning to use with Rails, and while doing so, I discovered I needed an XML representation of the configuration file.

The idea is that it's easier to select nodes from XPath than it is to tinker with individual array elements.

Here's an example:

    require 'lineparser'

    lines =<<LINES
    app_path: /tmp
    app: blog
    resources: posts

    welcome
      model
        foo
      controller + views
        index   v
          v: ... link_to "My Blog", controller: "posts" 
    LINES

      patterns = [
        [:root, 'app_path: :app_path', :app_path],
        [:root, 'app: :app', :app],
        [:root, 'resources: :resources', :resources],
        [:root, ':resource', :resource],
          [:resource, 'model', :model],
            [:model, ':class_name', :model_class],
          [:resource, /controller \+ views/, :resource_cv],
            [:resource_cv, /\w+\s+[av]{1,2}/, :resource_cv_av],
        [:all, /#/]
      ]

    lp = LineParser.new patterns
    r = lp.parse lines

output:

<pre>
&lt;?xml version='1.0' encoding='UTF-8'?&gt;
&lt;root&gt;
  &lt;app_path app_path='/tmp'&gt;app_path: /tmp&lt;/app_path&gt;
  &lt;app app='blog'&gt;app: blog&lt;/app&gt;
  &lt;resources resources='posts'&gt;resources: posts&lt;/resources&gt;
  &lt;resource resource='welcome'&gt;
    welcome
  model
      foo
  controller + views
      index   v
          v: ... link_to "My Blog", controller: "posts" 
    &lt;model&gt;
      model
  foo
      &lt;model_class class_name='foo'&gt;foo&lt;/model_class&gt;
    &lt;/model&gt;
    &lt;resource_cv&gt;
      controller + views
  index   v
      v: ... link_to "My Blog", controller: "posts" 
      &lt;resource_cv_av&gt;index   v
  v: ... link_to "My Blog", controller: "posts" &lt;/resource_cv_av&gt;
    &lt;/resource_cv&gt;
  &lt;/resource&gt;
&lt;/root&gt;
</pre>

The XML document however messy looking it appears does the job of representing the order and hierarchy of items as they appear in the configuration file. It also includes the matched keywords as node attributes, while storing the original lines below it within the node as text.


## Resources

* [jrobertson/lineparser](https://github.com/jrobertson/lineparser)

lineparser linetree parser configuration
