module NamedRecords
  def add_named_record name, record
    @named_records ||= {}
    @named_records[name] = record
  end

  def named_record name
    @named_records ? @named_records[name] : nil
  end
end
