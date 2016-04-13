class FixJavaClassMetadata < ActiveRecord::Migration
  def up
    # Update test results
    ActiveRecord::Base.connection.execute(%{
      UPDATE
        test_results
      SET
        custom_values = regexp_replace(custom_values::text, '"java\\.class"\\:".*?"', concat('"java.class":"', regexp_replace(custom_values->>'java.class', '.*\\.', ''), '"'))::json
      WHERE
        custom_values::jsonb ? 'java.class'
    })

    # Update test descriptions
    ActiveRecord::Base.connection.execute(%{
      UPDATE
        test_descriptions
      SET
        custom_values = regexp_replace(custom_values::text, '"java\\.class"\\:".*?"', concat('"java.class":"', regexp_replace(custom_values->>'java.class', '.*\\.', ''), '"'))::json
      WHERE
        custom_values::jsonb ? 'java.class'
    })
  end

  def down
  end
end
