const escape=(text:string)=>text.replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]!));
const keywords=new Set('and as assert async await begin break case catch class const continue create def default delete do else elif end enum except export extends false finally for from func function guard if import in insert interface into is lambda let match new nil none not null of or pass private public raise return select self static struct super switch table then throw true try type typeof union update var void when where while with yield'.split(' '));
// Lexical colouring only: source remains inert text and is never evaluated.
export function highlight(code:string,language='code'){
 const comment=language==='html'?String.raw`<!--[\s\S]*?(?:-->|$)`:language==='sql'?String.raw`--[^\n]*|\/\*[\s\S]*?(?:\*\/|$)`:String.raw`\/\/[^\n]*|\#[^\n]*|\/\*[\s\S]*?(?:\*\/|$)`;
 const tokens=new RegExp(comment+String.raw`|"(?:\\[\s\S]|[^"\\])*"?|'(?:\\[\s\S]|[^'\\])*'?|\x60(?:\\[\s\S]|[^\x60\\])*\x60?|\b\d+(?:\.\d+)?\b|\b[A-Za-z_]\w*\b`,'g');
 let result='',cursor=0;for(const match of code.matchAll(tokens)){result+=escape(code.slice(cursor,match.index));const value=match[0],kind=/^(?:\/\/|\/\*|#|--|<!--)/.test(value)?'comment':/^["'`]/.test(value)?'string':/^\d/.test(value)?'number':keywords.has(value.toLowerCase())?'keyword':'';result+=kind?`<span class="syntax-${kind}">${escape(value)}</span>`:escape(value);cursor=match.index+value.length;}return result+escape(code.slice(cursor));
}
export function codeEditor(id:string,value:string,language:string,draft=''){
 return `<div class="code-pane"><pre aria-hidden="true"><code>${highlight(value,language)}\n</code></pre><textarea id="${escape(id)}" data-language="${escape(language)}" ${draft?'data-draft="'+escape(draft)+'"':''} class="code-editor" wrap="off" spellcheck="false" autocapitalize="off" autocomplete="off" maxlength="100000">${escape(value)}</textarea></div>`;
}
export function bindCodeEditors(){
 document.querySelectorAll<HTMLTextAreaElement>('.code-pane textarea').forEach(editor=>{const pre=editor.previousElementSibling as HTMLPreElement;const sync=()=>{pre.scrollTop=editor.scrollTop;pre.scrollLeft=editor.scrollLeft;};editor.addEventListener('input',()=>{pre.firstElementChild!.innerHTML=highlight(editor.value,editor.dataset.language)+'\n';sync();});editor.addEventListener('scroll',sync);sync();});
}
