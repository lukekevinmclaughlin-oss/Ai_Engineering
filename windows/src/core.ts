import curriculum from '../content/curriculum.json';
import projectData from '../content/projects.json';
export interface Block {type:string;text:string;language?:string;items?:string[]}
export interface Challenge {prompt:string;instructions:string;starterCode?:string;solution?:string;testCases?:{input:string;expected:string}[];choices?:{id:string;text:string}[];correctChoiceID?:string;explanation:string;hints:string[]}
export interface Lesson {id:string;title:string;kind:string;estimatedMinutes:number;xp:number;summary:string;contentBlocks:Block[];challenge?:Challenge}
export interface Course {id:string;title:string;eyebrow:string;summary:string;accent:string;difficulty:string;estimatedMinutes:number;isFeatured:boolean;skills:string[];modules:{id:string;title:string;summary:string;lessons:Lesson[]}[]}
export interface Project {id:string;title:string;subtitle:string;summary:string;brief:string;difficulty:string;estimatedHours:number;xp:number;accent:string;skills:string[];outcomes:string[];milestones:{id:string;title:string;detail:string}[];starterFiles:{name:string;language:string;contents:string}[]}
export const courses=curriculum.courses as Course[],projects=projectData as Project[];
export const lessons=courses.flatMap(course=>course.modules.flatMap(module=>module.lessons.map(lesson=>({course,module,lesson}))));
export const lessonById=new Map(lessons.map(item=>[item.lesson.id,item]));
export const milestoneIds=new Set(projects.flatMap(p=>p.milestones.map(m=>p.id+'::'+m.id)));
export const draftIds=new Set([...lessons.map(x=>x.lesson.id),...projects.flatMap(p=>p.starterFiles.map(f=>p.id+'::'+f.name))]);
export const day=(date=new Date())=>`${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}-${String(date.getDate()).padStart(2,'0')}`;
export type State={version:1;completed:Record<string,string>;milestones:string[];bookmarks:string[];recent:string[];drafts:Record<string,string>;dailyGoal:number;theme:'dark'|'light'|'system';level:'firstSteps'|'guided'|'engineer';depth:'focused'|'deepDive';messages:Message[]};
export type Source={id:string;title:string;location:string;kind:string};
export type Message={role:'user'|'tutor';text:string;engine:string;sources:Source[]};
export function fresh():State{return {version:1,completed:{},milestones:[],bookmarks:[],recent:[],drafts:{},dailyGoal:100,theme:'dark',level:'firstSteps',depth:'deepDive',messages:[]};}
const object=(v:unknown):v is Record<string,unknown>=>!!v&&typeof v==='object'&&!Array.isArray(v);
function validDay(v:unknown){if(typeof v!=='string'||!/^\d{4}-\d{2}-\d{2}$/.test(v))return false;const d=new Date(v+'T12:00:00');return Number.isFinite(d.valueOf())&&day(d)===v;}
export function validate(value:unknown):State{
 if(!object(value)||value.version!==1||JSON.stringify(value).length>8_000_000)throw Error('Choose an AI Engineering version 1 backup under 8 MB.');
 const s=fresh();
 if(!object(value.completed)||!object(value.drafts))throw Error('Invalid progress records.');
 for(const [id,date] of Object.entries(value.completed)){if(!lessonById.has(id)||!validDay(date))throw Error('Unknown lesson or invalid completion date.');s.completed[id]=date as string;}
 for(const [id,text] of Object.entries(value.drafts)){if(!draftIds.has(id)||typeof text!=='string'||text.length>100_000)throw Error('Invalid workspace draft.');s.drafts[id]=text;}
 const array=(v:unknown,allowed:Set<string>,maximum:number)=>{if(!Array.isArray(v)||v.length>maximum||v.some(x=>typeof x!=='string'||!allowed.has(x)))throw Error('Invalid progress list.');return [...new Set(v)] as string[];};
 s.milestones=array(value.milestones,milestoneIds,160);s.bookmarks=array(value.bookmarks,new Set(courses.map(c=>c.id)),40);s.recent=array(value.recent,new Set(lessonById.keys()),12);
 if(!Number.isInteger(value.dailyGoal)||Number(value.dailyGoal)<20||Number(value.dailyGoal)>500)throw Error('Invalid daily goal.');s.dailyGoal=Number(value.dailyGoal);
 if(!['dark','light','system'].includes(String(value.theme))||!['firstSteps','guided','engineer'].includes(String(value.level))||!['focused','deepDive'].includes(String(value.depth)))throw Error('Invalid learning preferences.');
 s.theme=value.theme as State['theme'];s.level=value.level as State['level'];s.depth=value.depth as State['depth'];
 if(!Array.isArray(value.messages)||value.messages.length>100)throw Error('Invalid tutor history.');
 s.messages=value.messages.map(m=>{if(!object(m)||!['user','tutor'].includes(String(m.role))||typeof m.text!=='string'||m.text.length>32000||typeof m.engine!=='string'||m.engine.length>100||!Array.isArray(m.sources)||m.sources.length>5)throw Error('Invalid tutor message.');const sources=m.sources.map((v:unknown)=>{if(!object(v))throw Error('Invalid source.');const d=documents.find(d=>d.id===v.id);if(!d)throw Error('Unknown tutor source.');return source(d);});return {role:m.role as Message['role'],text:m.text,engine:m.engine,sources};});
 return s;
}
export function complete(s:State,id:string,date=new Date()):number{const record=lessonById.get(id);if(!record)throw Error('Unknown lesson.');s.recent=[id,...s.recent.filter(x=>x!==id)].slice(0,12);if(s.completed[id])return 0;s.completed[id]=day(date);return record.lesson.xp;}
export function metrics(s:State,now=new Date()){
 const daily:Record<string,number>={},skills:Record<string,number>={};let xp=0;
 for(const [id,date] of Object.entries(s.completed)){const r=lessonById.get(id)!;xp+=r.lesson.xp;daily[date]=(daily[date]||0)+r.lesson.xp;for(const skill of r.course.skills)skills[skill]=(skills[skill]||0)+Math.max(1,Math.floor(r.lesson.xp/Math.max(1,r.course.skills.length)));}
 const cursor=new Date(now);let streak=0;if(!daily[day(cursor)])cursor.setDate(cursor.getDate()-1);while(daily[day(cursor)]){streak++;cursor.setDate(cursor.getDate()-1);}
 return {xp,daily,skills,streak,today:daily[day(now)]||0,finished:Object.keys(s.completed).length};
}
export function checkLesson(l:Lesson,answer:string){
 const c=l.challenge;if(!c)return {pass:true,message:'Lesson reviewed.'};
 if(c.correctChoiceID)return {pass:answer===c.correctChoiceID,message:answer===c.correctChoiceID?'Correct. '+c.explanation:'Try again. Review the material or reveal a hint.'};
 if(c.starterCode!==undefined){
  const code=answer.trim(),starter=c.starterCode.trim();if(!code||code===starter)return {pass:false,message:'Change the guided starter before checking your approach.'};
  const ignored=new Set(['from','import','return','class','def','async','await','self','true','false','none','string','float','list','dict']);
  const tokens=(s:string)=>new Set(s.toLowerCase().split(/[^\p{L}\p{N}_]+/u).filter(x=>x.length>=4&&!ignored.has(x)));
  const expected=tokens(c.solution||''),actual=tokens(code);const pass=expected.size?[...expected].filter(x=>actual.has(x)).length/expected.size>=.52:code.length>24;
  return {pass,message:pass?'Your approach matches the reference concepts. This is a text-based review, not code execution.':'Some reference concepts are missing. Use a hint or compare the worked solution. No code was executed.'};
 }
 return {pass:answer.trim().length>=8,message:answer.trim().length>=8?'Reflection saved. Compare your reasoning with the explanation; this is self-assessment.':'Write a short reflection before marking this lesson reviewed.'};
}
export function checkProject(text:string,starter:string){const changed=text!==starter,placeholders=/NotImplementedError|TODO|# Your code here|\/\/ Your code here/i.test(text);return {pass:text.length>80&&changed&&!placeholders,changed,placeholders,message:'Local structure check only: no code was executed and no test assertions were evaluated.'};}
const toggle=(list:string[],id:string)=>list.includes(id)?list.filter(x=>x!==id):[...list,id];
export function bookmark(s:State,id:string){if(!courses.some(c=>c.id===id))throw Error('Unknown course.');s.bookmarks=toggle(s.bookmarks,id);}
export function milestone(s:State,id:string){if(!milestoneIds.has(id))throw Error('Unknown milestone.');s.milestones=toggle(s.milestones,id);}
type Document=Source&{summary:string;body:string;keywords:string[]};
export const documents:Document[]=[...lessons.map(({course,module,lesson:l})=>({id:l.id,title:l.title,kind:'lesson',location:course.title+' · '+module.title,summary:l.summary,body:[...l.contentBlocks.map(b=>[b.text,...b.items||[]].join('\n')),l.challenge?.prompt,l.challenge?.instructions,l.challenge?.explanation].filter(Boolean).join('\n\n'),keywords:[...course.skills,course.title,module.title,l.kind]})),...projects.map(p=>({id:p.id,title:p.title,kind:'project',location:'Portfolio project · '+p.difficulty,summary:p.summary,body:[p.brief,...p.outcomes,...p.milestones.map(m=>m.detail)].join('\n\n'),keywords:[...p.skills,p.subtitle,p.difficulty]}))];
const stop=new Set('a an and are as at be can do does for from how i in is it me my of on or that the this to what when where which why with would you'.split(' '));
const norm=(s:string)=>s.normalize('NFD').replace(/\p{M}/gu,'').toLowerCase();
const tokens=(s:string)=>norm(s).split(/[^\p{L}\p{N}]+/u).filter(s=>s.length>1&&!stop.has(s));
const synonyms:Record<string,string[]>= {rag:['retrieval','grounding','vector','citation'],llm:['language','model','transformer','token'],hallucination:['grounding','evaluation','factual','retrieval'],fast:['latency','inference','caching','serving'],cheap:['cost','token','caching','routing'],safe:['safety','guardrail','security','approval'],chatbot:['conversation','assistant','prompt','language'],database:['data','storage','vector','retrieval'],math:['probability','vector','gradient','matrix']};
const indexed=documents.map(d=>({d,fields:[d.title,d.keywords.join(' '),d.summary,d.body].map(x=>new Set(tokens(x)))}));
export const source=(d:Document):Source=>({id:d.id,title:d.title,location:d.location,kind:d.kind});
export function rank(question:string,context='',limit=5){const query=new Set(tokens(question));for(const t of [...query])for(const extra of synonyms[t]||[])query.add(extra);const contextCourse=lessonById.get(context)?.course.title;
 return indexed.map(({d,fields})=>({d,score:[...query].reduce((v,t)=>v+fields.reduce((a,set,i)=>a+(set.has(t)?[7,5,3,1][i]:0),0),0)+(d.id===context?80:0)+(contextCourse&&d.location.includes(contextCourse)?15:0)})).filter(x=>x.score>=3).sort((a,b)=>b.score-a.score||a.d.title.localeCompare(b.d.title)).slice(0,limit).map(x=>x.d);
}
const analogies:[RegExp,string][]=[[/retrieval|rag/i,'Retrieval is an open-book exam: find the right pages before composing an answer.'],[/embedding|vector|semantic/i,'Embeddings place ideas on a map, where related meanings have nearby coordinates.'],[/agent|tool/i,'An agent is an apprentice. Every real action needs a named tool and clear permissions.'],[/evaluation|eval|quality/i,'Evals are repeatable crash tests; a pleasant demonstration is only one drive around the block.'],[/neural|training|gradient/i,'Training adjusts many small knobs, using examples to move each toward a better result.'],[/token|language model|transformer/i,'A language model predicts the next small piece of text from the pieces it has already seen.'],[/api|request|response/i,'An API is an order slip defining the request and the shape of the response.'],[/latency|serving|inference/i,'Serving is a busy kitchen: batches increase throughput, but waiting too long slows each customer.'],[/security|guardrail|injection/i,'Treat model output as untrusted input. Permissions and validation belong in surrounding code.'],[/data|dataset/i,'A dataset is a practice workbook. Poor examples can teach the wrong behavior.']];
export function offlineAnswer(question:string,context:string,s:Pick<State,'level'|'depth'>):Message{
 const matches=rank(question,context,s.depth==='deepDive'?5:3),p=matches[0];
 if(!p)return {role:'tutor',text:'I could not confidently match this question to the bundled material. Add the lesson, concept, error message, or system component you are working on. Your question stayed on this device.',engine:'Offline Core',sources:[]};
 const paragraphs=p.body.split('\n').map(x=>x.trim()).filter(x=>x.length>55&&!x.includes('NotImplementedError')).slice(0,5).map(x=>x.slice(0,720));
 const intro=s.level==='firstSteps'?'Start with one small idea; you do not need advanced maths.':s.level==='guided'?'Connect the intuition to basic Python and look for common mistakes.':'Separate the mechanism, assumptions, failure modes, and production trade-offs.';
 const sections=['Short answer\n'+p.summary,'Build the mental model\n'+intro+' '+(paragraphs[0]||p.summary),'A useful analogy\n'+(analogies.find(([re])=>re.test(p.title+' '+p.summary+' '+p.keywords.join(' ')))?.[1]||'An AI system is a workshop. The model is one tool; data, validation, monitoring and people make the workshop dependable.')];
 if(s.depth==='deepDive')sections.push('How the pieces fit\n'+matches.slice(0,4).map((m,i)=>`${i+1}. ${m.title}: ${m.summary}`).join('\n\n'),'Under the hood\n'+paragraphs.slice(1,3).join('\n\n'),'Engineering lens\nDefine desired behavior. Test normal and hostile inputs. Measure quality, latency and cost. Decide what must be deterministic and when a human should review the result.');
 sections.push('Try it now\n'+(p.body.split('\n').filter(x=>x.length>35).at(-1)?.slice(0,520)||'Draw the flow as boxes and arrows; label inputs, outputs, validation and failure handling.'),'Check your understanding\nExplain the idea in one sentence. Name one input, one output and one failure mode. Compare your answer with the sources below.','Offline Core retrieves and organizes bundled course material. It does not run a generative model. Optional connected models must be enabled explicitly.');
 return {role:'tutor',text:sections.join('\n\n'),engine:'Offline Core',sources:matches.map(source)};
}
export function grounding(question:string,context:string){return rank(question,context).map((d,i)=>`SOURCE ${i+1}: ${d.title}\nLOCATION: ${d.location}\nSUMMARY: ${d.summary}\nMATERIAL:\n${d.body.slice(0,2800)}`).join('\n\n---\n\n');}
