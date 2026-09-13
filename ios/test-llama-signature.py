#!/usr/bin/env python3
"""Local signing regression tests. Requires macOS/Xcode; no Apple identity needed."""
import pathlib, subprocess, shutil, plistlib, tempfile, atexit
repo=pathlib.Path(__file__).resolve().parent.parent
root=pathlib.Path(tempfile.mkdtemp(prefix='llama-signature-tests-'))
atexit.register(shutil.rmtree, root)
check=repo/'ios/verify-llama-signature.sh'
source=repo/'ios/llama.xcframework/ios-arm64/llama.framework'
def run(*args):
 return subprocess.run([str(a) for a in args],capture_output=True,text=True)
def verify(path,good):
 p=run(check,path)
 assert (p.returncode==0)==good, p.stdout+p.stderr
 if not good: assert 'error:' in p.stderr, p.stderr
 print(('PASS valid: ' if good else 'PASS rejected: ')+str(path.relative_to(root) if path.is_relative_to(root) else path))
def copy(name):
 dest=root/name/'llama.framework'; shutil.copytree(source,dest,dirs_exist_ok=True); return dest
for name,args in [('preserved', ['--preserve-metadata=identifier,entitlements,flags']),('default',[]),('bad-id',['--identifier','llama-regression-invalid-identifier'])]:
 fw=copy(name); p=run('codesign','--force','--sign','-',*args,fw); assert p.returncode==0,p.stderr; verify(fw,name!='bad-id')
fw=copy('unsigned'); assert run('codesign','--remove-signature',fw).returncode==0; verify(fw,False)
fw=copy('wrong-plist'); p=fw/'Info.plist'; data=plistlib.loads(p.read_bytes()); data['CFBundleIdentifier']='org.example.wrong'; p.write_bytes(plistlib.dumps(data)); verify(fw,False)
fw=copy('tampered'); (fw/'Headers/llama.h').write_text('tampered'); verify(fw,False)
fw=copy('missing-binary'); (fw/'llama').unlink(); verify(fw,False)
(root/'empty').mkdir(exist_ok=True); verify(root/'empty',False)
archive=root/'fixture.xcarchive'; fw=archive/'Products/Applications/Fixture.app/Frameworks/llama.framework'; shutil.copytree(source,fw,dirs_exist_ok=True); verify(archive,True)
payload=root/'ipa/Payload/Fixture.app/Frameworks/llama.framework'; shutil.copytree(source,payload,dirs_exist_ok=True)
ipa=root/'fixture.ipa'; assert run('ditto','-c','-k','--keepParent',root/'ipa/Payload',ipa).returncode==0; verify(ipa,True)
for fw in (repo/'ios/llama.xcframework').glob('*/llama.framework'): verify(fw,True)
manifest=plistlib.loads((repo/'ios/llama.xcframework/Info.plist').read_bytes())
for lib in manifest['AvailableLibraries']:
 fw=repo/'ios/llama.xcframework'/lib['LibraryIdentifier']/lib['LibraryPath']
 arch=run('lipo','-archs',fw/'llama').stdout.split(); assert sorted(arch)==sorted(lib['SupportedArchitectures'])
 print('PASS manifest architectures:',lib['LibraryIdentifier'],arch)

# Execute the actual project phase, so unsigned builds cannot bypass ID checks.
import json, os
project=run('plutil','-convert','json','-o','-',repo/'ios/Runner.xcodeproj/project.pbxproj')
assert project.returncode==0, project.stderr
objects=json.loads(project.stdout)['objects']
phase=next(v['shellScript'] for v in objects.values() if v.get('name')=='Verify llama signature')
fw=copy('build-phase')
env=os.environ.copy()
env.update(PROJECT_DIR=str(repo/'ios'),TARGET_BUILD_DIR=str(root),FRAMEWORKS_FOLDER_PATH='build-phase')
for allowed in ['YES','NO']:
 env['CODE_SIGNING_ALLOWED']=allowed
 result=subprocess.run(['/bin/bash','-c',phase],env=env,capture_output=True,text=True)
 assert result.returncode==0, result.stderr
assert run('codesign','--force','--sign','-','--identifier','llama-invalid-regression',fw).returncode==0
for allowed in ['YES','NO']:
 env['CODE_SIGNING_ALLOWED']=allowed
 result=subprocess.run(['/bin/bash','-c',phase],env=env,capture_output=True,text=True)
 assert result.returncode!=0 and 'error:' in result.stderr
 print('PASS build guard rejects mismatch: CODE_SIGNING_ALLOWED='+allowed)
