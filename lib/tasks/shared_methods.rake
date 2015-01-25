def rescue_me(e)
  puts e
  case e.io.status[0]
  when "403"
    puts "Error...Forbidden...Skipped"
    return 2
  when "404"
    return attempt_retry
  else #500
    return attempt_retry
  end
end

def attempt_retry
  @tries += 1
  if @tries < 3
    puts "Attempting to Retry..." + @tries.to_s + "...In 5 Seconds"
    sleep 5
    return 1
  else
    puts "Skipped the page"
    return 2
  end
end