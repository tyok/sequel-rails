def pretend_file_not_exists pattern
  allow(IO).to receive(:read).and_wrap_original do |m, *a|
    if pattern === a.first
      raise Errno::ENOENT
    else
      m.call *a
    end
  end
end
