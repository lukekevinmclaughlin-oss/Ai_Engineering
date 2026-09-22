const fs=require('node:fs'),path=require('node:path'),{execFileSync}=require('node:child_process'),{createHash}=require('node:crypto');
const root=path.resolve(__dirname,'..'),exe=path.join(root,'release/win-unpacked/AI Engineering.exe');
const files=['index.html',...fs.readdirSync(path.join(root,'dist/assets')).map(name=>'assets/'+name)];
const script=`const fs=require('node:fs'),path=require('node:path'),{createHash}=require('node:crypto');const root=process.argv[1],files=JSON.parse(process.argv[2]);const hashes={};for(const file of files)hashes[file]=createHash('sha256').update(fs.readFileSync(path.join(root,'dist',file))).digest('hex');console.log(JSON.stringify({versions:process.versions,hashes,main:fs.existsSync(path.join(root,'electron/main.cjs')),preload:fs.existsSync(path.join(root,'electron/preload.cjs')),notices:fs.statSync(path.join(root,'resources/THIRD-PARTY-NOTICES.txt')).size}));`;
const result=JSON.parse(execFileSync(exe,['-e',script,path.join(root,'release/win-unpacked/resources/app.asar'),JSON.stringify(files)],{env:{...process.env,ELECTRON_RUN_AS_NODE:'1'},windowsHide:true,encoding:'utf8',timeout:30000}));
if(!result.main||!result.preload||!result.notices)throw new Error('Packaged files are missing.');
for(const file of files){const expected=createHash('sha256').update(fs.readFileSync(path.join(root,'dist',file))).digest('hex');if(result.hashes[file]!==expected)throw new Error('Packaged asset differs: '+file);}
const report={passed:true,electron:result.versions.electron,node:result.versions.node,verifiedAssets:result.hashes,noticesBytes:result.notices,nativeWindowTested:false,nativeDialogsTested:false};
fs.writeFileSync(path.join(root,'release/packaged-verification.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report));
