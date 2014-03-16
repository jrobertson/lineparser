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
      [:all, /#/, :comment]
    ]

    lp = LineParser.new patterns
    r = lp.parse lines

output observed:

<pre>
[
  [:resources, {":resources"=>"posts"}, ["resources: posts"], nil], 
  [:comment, {:captures=>[]}, ["# winning"], nil], 
  [:comment, {:captures=>[]}, ["#"], nil], 
  [:resource, {":resource"=>"post"}, ["post", ["model", ["Post", ["orange 123"], ["fff"]]]], [
    [:model, {}, ["model", ["Post", ["orange 123"], ["fff"]]], [
      [:model_class, {":class_name"=>"Post"}, ["Post", ["orange 123"], ["fff"]], [
        [:model_class_attribute, {:captures=>["123"]}, ["orange 123"], nil]
      ]]
    ]]
  ]],
  [:resource, {":resource"=>"comments"}, ["comments", ["model", ["Comment", ["orange 576"], ["ggg"]]]], [
    [:model, {}, ["model", ["Comment", ["orange 576"], ["ggg"]]], [
      [:model_class, {":class_name"=>"Comment"}, ["Comment", ["orange 576"], ["ggg"]], [
        [:model_class_attribute, {:captures=>["576"]}, ["orange 576"], nil]
      ]]
    ]]
  ]]
] 

</pre>


## Resources

* [jrobertson/lineparser](https://github.com/jrobertson/lineparser)

lineparser linetree parser configuration
