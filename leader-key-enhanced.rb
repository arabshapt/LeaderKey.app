cask "leader-key-enhanced" do
  version "1.16.0-enhanced"
  sha256 "7660b333b02acf98474cac3a71549a9a03f218c2de748470d81ad10faf730359"

  url "https://drive.google.com/uc?export=download&id=1E6BcdelZ6FYXwM4fTGTyyY5_PBEsLOxb"
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