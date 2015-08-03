module NamedRecords
  def add_named_record name, record
    @named_records ||= {}
    @named_records[name] = record
  end

  def named_record name
    record = @named_records.try :[], name
    raise "Unknown named record #{name.inspect}" unless record
    record
  end
end
