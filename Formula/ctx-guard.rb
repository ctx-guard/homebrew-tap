# Rendered by packaging/render.sh for each release and pushed to
# https://github.com/ctx-guard/homebrew-tap as Formula/ctx-guard.rb, so
# `brew install ctx-guard/tap/ctx-guard` installs it.
class CtxGuard < Formula
  desc "Local hooks that check AI agents' package installs and shrink long output"
  homepage "https://github.com/viktor-tapovski/ctx-guard"
  url "https://github.com/viktor-tapovski/ctx-guard/releases/download/v0.11.0/ctx-guard-0.11.0.tar.gz"
  sha256 "bb11c2007e8229bb85f31fdfadc09dc61156fc91b115e9668dfc487c1086239a"
  license "MIT"

  depends_on "python@3.13"

  def install
    libexec.install Dir["*"]
    # The hooks run with this Python, recorded in each agent's config at
    # `ctx-guard install` time.
    (bin/"ctx-guard").write_env_script libexec/"bin/ctx-guard",
      CTX_GUARD_PYTHON: Formula["python@3.13"].opt_bin/"python3.13"
  end

  def caveats
    <<~EOS
      Homebrew installs the files only. To set up your agents, run:
        ctx-guard install
      and pick them from the checklist (or pass --agents claude-code,codex-cli).

      After `brew upgrade ctx-guard`, run `ctx-guard install` again: the
      hooks are copied into ~/.ctx-guard and don't update by themselves.

      To remove ctx-guard from your agents, run `ctx-guard uninstall`
      before `brew uninstall ctx-guard`.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ctx-guard --version")
    (testpath/".codex").mkpath
    system bin/"ctx-guard", "install", "--agents", "codex-cli"
    assert_match "CTX_GUARD_AGENT=codex-cli", (testpath/".codex/hooks.json").read
    system bin/"ctx-guard", "uninstall"
    refute_path_exists testpath/".codex/hooks.json"
  end
end
