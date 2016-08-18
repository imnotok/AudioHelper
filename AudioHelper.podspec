#
#  Be sure to run `pod spec lint AudioHelper.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "AudioHelper"
  s.version      = "0.0.1"
  s.summary      = "A record class which is userfriendly and esay to use by developers."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  AVAudioRecorder, AudioRecorderaudio,AVAudioRecorder,AudioRecorderrecord audiorecord, aac, wav, record class
                   DESC

  s.homepage     = "https://github.com/imnotok/AudioHelper"

  s.license      = "MIT"

  s.author             = { "imnotok" => "imnotok@foxmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/imnotok/AudioHelper.git", :tag => "#{s.version}" }

  s.source_files  =  'AudioHelpTest/AudioHelper/*.{h,m}'
  s.frameworks = 'Foundation', 'AVFoundation'
  s.requires_arc = true

end
