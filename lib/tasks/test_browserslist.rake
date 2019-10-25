desc "Test .browserslistrc"
task :test_browserslist => :environment do

  # Set up so needs basically no polyfilling
  File.write(Rails.root.join('.browserslistrc'), 'Chrome 77')

  %x(rm -r public/packs; bin/spring stop; bin/webpack;) # Webpack

  js_path = ['public', 'packs', 'js']

  initial_size = 0 # bytes

  # Iterate through all the files in case the polyfills come in a separate
  # file I wasn't aware of
  Dir.each_child(Rails.root.join(*js_path)) do |file|
    next if file.include?('.map')

    initial_size += File.new(Rails.root.join(*js_path, file)).size
  end

  # Now, do it again but with really aggressive browserslistrc
  File.write(Rails.root.join('.browserslistrc'), '> 0.1%')

  %x(rm -r public/packs; bin/spring stop; bin/webpack;) # Webpack

  new_size = 0 # bytes

  Dir.each_child(Rails.root.join(*js_path)) do |file|
    next if file.include?('.map')

    new_size += File.new(Rails.root.join(*js_path, file)).size
  end

  3.times { puts }

  if new_size == initial_size
    puts "Nope! They were both the same size at #{new_size}b"
  else
    puts "It worked! New: #{new_size} is different from old: #{initial_size}"
  end

  3.times { puts }
end
