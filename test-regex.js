
const updateExpr = 'SET #attr0 = :val0, #attr1 = :val1';
const attrKey = '#attr1';
const escapedAttrKey = attrKey.replace('#', '\\\\#');
const regex = new RegExp(escapedAttrKey + '\\\s*=\\\s*(:[a-zA-Z0-9_]+)');
console.log(updateExpr.match(regex));

