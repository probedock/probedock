module ApiParamsHelper
  def true_flag? name
    !!params[name].to_s.match(/\A(?:1|y|yes|t|true)\Z/i)
  end

  def false_flag? name
    !!params[name].to_s.match(/\A(?:0|n|no|f|false)\Z/i)
  end
end
