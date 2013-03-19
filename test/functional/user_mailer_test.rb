require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "fund_data_imported" do
    mail = UserMailer.fund_data_imported
    assert_equal "Fund data imported", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
