const fs = require('fs');
const path = require('path');

function walk(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(function(file) {
    file = path.join(dir, file);
    const stat = fs.statSync(file);
    if (stat && stat.isDirectory()) { 
      results = results.concat(walk(file));
    } else { 
      if (file.endsWith('.dart')) results.push(file);
    }
  });
  return results;
}

const files = walk('lib');
for (const file of files) {
  const content = fs.readFileSync(file, 'utf8');
  // Simple regex to replace Navigator.pop(context) if it's not already preceded by if (Navigator.canPop(context))
  // We'll just replace it unconditionally if it matches exact string and not the safe version.
  let newContent = content;
  // A bit brute force but works:
  // First, undo if already safe to normalize (just in case)
  newContent = newContent.replace(/if\s*\(\s*Navigator\.canPop\(context\)\s*\)\s*Navigator\.pop\(context\)/g, 'Navigator.pop(context)');
  // Then apply safe
  newContent = newContent.replace(/Navigator\.pop\(context\)/g, 'if (Navigator.canPop(context)) Navigator.pop(context)');
  
  if (content !== newContent) {
    fs.writeFileSync(file, newContent, 'utf8');
    console.log('Fixed', file);
  }
}
