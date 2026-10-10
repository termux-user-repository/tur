'use strict';
// Electron's c-ares only reads /etc/resolv.conf, which Termux does not have
const dns = require('dns');
const fs = require('fs');

try {
  const servers = fs
    .readFileSync('@TERMUX_PREFIX@/etc/resolv.conf', 'utf8')
    .split('\n')
    .map((line) => /^\s*nameserver\s+(\S+)/.exec(line)?.[1])
    .filter(Boolean);
  if (servers.length > 0) {
    dns.setServers(servers);
  }
} catch {
  // keep the default resolver config
}
