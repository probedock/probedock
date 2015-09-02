module NamedRecordsSpecHelper
  def add_named_record name, record
    @named_records ||= {}
    raise "A named record already exists for name #{name.inspect}" if @named_records[name]
    @named_records[name] = record
  end

  def named_record name
    record = @named_records.try :[], name
    raise "Unknown named record #{name.inspect}" unless record
    record
  end
end
