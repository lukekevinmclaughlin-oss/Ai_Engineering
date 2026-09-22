import {day,lessons,type State} from './core';
export function momentum(s:State,now=new Date()){
 const days=Array.from({length:7},(_,i)=>{const date=new Date(now.getFullYear(),now.getMonth(),now.getDate());date.setDate(date.getDate()-6+i);return {day:day(date),label:date.toLocaleDateString(undefined,{weekday:'short'}),xp:0};});
 for(const {lesson} of lessons){const bucket=days.find(d=>d.day===s.completed[lesson.id]);if(bucket)bucket.xp+=lesson.xp;}
 return days;
}
export function momentumView(s:State){const days=momentum(s),maximum=Math.max(1,...days.map(d=>d.xp)),total=days.reduce((n,d)=>n+d.xp,0);return `<section class="panel"><div class="section-title"><h2>Weekly momentum</h2><strong>${total} XP · last 7 days</strong></div><p>XP earned from first lesson completions, by local calendar day.</p><ol class="momentum">${days.map(d=>`<li aria-label="${d.day}: ${d.xp} XP"><strong>${d.xp}</strong><div class="momentum-track" aria-hidden="true"><span style="height:${d.xp/maximum*100}%"></span></div><span>${d.label}</span><small>${d.day.slice(5)}</small></li>`).join('')}</ol></section>`;}
