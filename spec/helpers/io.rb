def pretend_file_not_exists(pattern)
  allow(IO).to receive(:read).and_wrap_original do |m, *a|
    # if this isn't a good use for case equality I don't know what is
    if pattern === a.first # rubocop:disable CaseEquality
      fail Errno::ENOENT
    else
      m.call(*a)
    end
  end
end
