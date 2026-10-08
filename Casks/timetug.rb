cask "timetug" do
  version "2.0.0"
  sha256 "3b9da381ee2f9ff9684b84086cd5409376a6d6b08eccc65624beedeb898300f8"

  url "https://github.com/darkarena1/timetug/releases/download/v#{version}/TimeTug-#{version}.dmg"
  name "TimeTug"
  desc "Menu bar timer that tracks time against your calendar"
  homepage "https://github.com/darkarena1/timetug"

  # Stable releases only: `latest` on GitHub never points at a pre-release.
  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :sonoma

  app "TimeTug.app"

  zap trash: [
    "~/Library/Application Scripts/com.timetug.app*",
    "~/Library/Containers/com.timetug.app*",
    "~/Library/Group Containers/*.com.timetug.shared",
  ]
end
