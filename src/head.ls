semver = if window? => window.semver else if module? and require? => require "@plotdb/semver" else null
fetch = if window? => window.fetch else if module? and require? => require "node-fetch" else null
require! <[fs]>
