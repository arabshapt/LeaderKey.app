cask "leader-key-enhanced" do
  version "1.16.0-enhanced"
  sha256 "33bc396b3966f44f3047995c1fe3e23727ed48b189696a53c51e342114695028"

  url "https://drive.google.com/uc?export=download&id=1XkhhDJ3TCKMmmYsS3LzaOYjqlEzFKv_K"
  name "Leader Key Enhanced"
  desc "Enhanced fork of Leader Key - The faster than your launcher launcher"
  homepage "https://github.com/arabshapt/LeaderKey.app"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"

  app "Leader Key.app"

  zap trash: [
    "~/Library/Application Support/Leader Key",
    "~/Library/Caches/Leader Key",
    "~/Library/Preferences/Leader Key.plist",
    "~/Library/Saved Application State/Leader Key.savedState",
  ]
end