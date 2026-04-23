const fs = require('fs');
const path = require('path');

const files = [
  'd:/insurance-qa/collections/insurance-enterprise-v1-stable.json',
  'd:/insurance-qa/collections/insurance-enterprise-v2-complete.json'
];

files.forEach(file => {
  const name = path.basename(file);
  try {
    const raw = fs.readFileSync(file, 'utf8');
    
    // Check for BOM
    if (raw.charCodeAt(0) === 0xFEFF) {
      console.log(name + ': ⚠️  BOM detected at start (byte order mark - can cause import failures)');
    }
    
    // Check for null bytes
    if (raw.includes('\0')) {
      console.log(name + ': ❌ NULL bytes found in file');
    }
    
    const parsed = JSON.parse(raw);
    console.log('---');
    console.log(name + ': ✅ JSON VALID');
    console.log('  _postman_id : ' + parsed.info._postman_id);
    console.log('  name        : ' + parsed.info.name);
    console.log('  schema      : ' + parsed.info.schema);
    console.log('  folders     : ' + parsed.item.length);
    console.log('  size (KB)   : ' + Math.round(raw.length / 1024));
    
    // Check all folder names
    parsed.item.forEach((folder, i) => {
      console.log('  [' + i + '] ' + folder.name + ' (' + (folder.item ? folder.item.length : 0) + ' tests)');
    });
    
  } catch(e) {
    console.log('---');
    console.log(name + ': ❌ PARSE ERROR');
    console.log('  ' + e.message);
    
    // Find exact location of error
    if (e.message.includes('position')) {
      const pos = parseInt(e.message.match(/position (\d+)/)?.[1] || '0');
      if (pos > 0) {
        const raw = fs.readFileSync(file, 'utf8');
        console.log('  Error near: ...', JSON.stringify(raw.substring(Math.max(0, pos-50), pos+50)), '...');
      }
    }
  }
});
