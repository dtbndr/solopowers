#!/usr/bin/env node
// Fails when a quoted edge endpoint in a ```dot digraph is never declared
// as a node (`"label" [shape=...]`) in the same digraph. Usage: node lint-dot-nodes.js <file.md>...
const fs = require('fs');

let bad = 0;
for (const file of process.argv.slice(2)) {
  const md = fs.readFileSync(file, 'utf8');
  const re = /```dot\n([\s\S]*?)```/g;
  let m;
  while ((m = re.exec(md))) {
    const body = m[1];
    const name = (body.match(/digraph\s+(\w+)/) || [, '?'])[1];
    const declared = new Set();
    const decl = /^\s*"((?:[^"\\]|\\.)*)"\s*\[/gm; // node statement starts the line
    let d;
    while ((d = decl.exec(body))) declared.add(d[1]);
    const edge = /"((?:[^"\\]|\\.)*)"\s*->\s*"((?:[^"\\]|\\.)*)"/g;
    let e;
    while ((e = edge.exec(body))) {
      for (const end of [e[1], e[2]]) {
        if (!declared.has(end)) {
          console.log(`${file}: digraph ${name}: undeclared edge endpoint: "${end}"`);
          bad++;
          declared.add(end); // report once
        }
      }
    }
  }
}
process.exit(bad ? 1 : 0);
