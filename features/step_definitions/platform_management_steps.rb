Then /the response body should be a JSON array with the following tables:/ do |tables|
  raise 'No response body found' unless @response_body

  response_table_names = @response_body.collect{ |elem| elem['name'] }.sort
  expected_table_names = tables.split("\n").collect{ |name| name.strip }.sort

  expect(response_table_names).to eq(expected_table_names)

  @response_body.each do |elem|
    expect(elem['rowsCount']).to be_a_kind_of(Fixnum), "table #{elem['name']} expected Fixnum for rowsCount but got #{elem['rowsCount'].class}"
    expect(elem['tableSize']).to be_a_kind_of(Fixnum), "table #{elem['name']} expected Fixnum for tableSize but got #{elem['tableSize'].class}"
    expect(elem['indexesSize']).to be_a_kind_of(Fixnum), "table #{elem['name']} expected Fixnum for indexesSize but got #{elem['indexesSize'].class}"
    expect(elem['totalSize']).to be_a_kind_of(Fixnum), "table #{elem['name']} expected Fixnum for totalSize but got #{elem['totalSize'].class}"
    expect(elem['rowsCount']).to be >= 0, "table #{elem['name']} expected rowsCount to be >= 0 but got #{elem['rowsCount']}"
    expect(elem['tableSize']).to be >= 0, "table #{elem['name']} expected tableSize to be >= 0 but got #{elem['tableSize']}"
    expect(elem['indexesSize']).to be >= 0, "table #{elem['name']} expected indexesSize to be >= 0 but got #{elem['indexesSize']}"
    expect(elem['totalSize']).to be >= 0, "table #{elem['name']} expected totalSize to be >= 0 but got #{elem['totalSize']}"
  end
end

Then /the following tables should contain trends:/ do |tables|
  raise 'No response body found' unless @response_body

  expected_table_names = tables.split("\n").collect{ |name| name.strip }

  @response_body.each do |elem|
    if expected_table_names.find_index(elem['name'])
      expect(elem['rowsCountTrend']).to be_a_kind_of(Array), "table #{elem['name']} expected to have an trend array for rowsCountTrend but got #{elem['rowsCountTrend'].class}"
      expect(elem['rowsCountTrend'].size).to eq(5), "table #{elem['name']} expected to be an array of five elements but got #{elem['rowsCountTrend'].size} element(s)"

      elem['rowsCountTrend'].each.with_index do |trend_elem, idx|
        expect(trend_elem).to be_a_kind_of(Fixnum), "table #{elem['name']} expected to have the trend element ##{idx} to be Fixnum but got #{elem['rowsCountTrend'][idx].class}"
        expect(trend_elem).to be >= 0, "table #{elem['name']} expected to have the trend element ##{idx} to be >= 0 but got #{elem['rowsCountTrend'][idx]}"
      end
    else
      expect(elem['rowsCountTrend']).to be_nil, "table #{elem['name']} not to have the attribute rowsCountTrend but it was present"
    end
  end
end

