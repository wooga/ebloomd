guard 'shell' do
  interactor :off

  watch(%r{((?:src|test)/(.*?)(?:_test)?.erl)}) do |md|
    files = Dir['**/**.erl']
    tests  = files.grep(/#{suite}_test/).grep /test/

    tests.each do |t|
        print `script/rebar compile skip_deps=true && \
          script/test-runner #{t} | script/test-filter`
    end

    if tests.empty?
        puts "\x1b[1;31mNo tests found for `#{md[0]}`\x1b[0m"
    end
  end
end
