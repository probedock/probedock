class StripInvalidUnicodeCharacters < ActiveRecord::Migration
  def change
    stuck_payloads = TestPayload.where(state: 'created').to_a
    say "found #{stuck_payloads.length} payloads stuck in created state"

    invalid_payloads = stuck_payloads.select do |payload|
      MultiJson.dump(payload.contents).match(/\\u0000/).present?
    end

    say_with_time "fixing #{invalid_payloads.length} payloads with invalid unicode characters" do
      invalid_payloads.each do |payload|
        raw_contents = MultiJson.dump(payload.contents)
        fixed_contents = MultiJson.load(raw_contents.gsub(/\\u0000/, ''))
        TestPayload.where(id: payload.id).update_all contents: fixed_contents
      end
    end

    say_with_time "queuing #{stuck_payloads.length} processing jobs" do
      stuck_payloads.length.times do
        Resque.enqueue ProcessNextTestPayloadJob
      end
    end
  end
end
