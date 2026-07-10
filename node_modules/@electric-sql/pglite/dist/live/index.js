import{u as I,v as O,w as C}from"../chunk-3WWIVTCY.js";import{j as P}from"../chunk-QY3QWFKW.js";P();var M=5,U=async(E,y)=>{let p=new Set,$={async query(e,g,a){let m,l,_;if(typeof e!="string"&&(m=e.signal,g=e.params,a=e.callback,l=e.offset,_=e.limit,e=e.query),l===void 0!=(_===void 0))throw new Error("offset and limit must be provided together");let t=l!==void 0&&_!==void 0,T;if(t&&(typeof l!="number"||isNaN(l)||typeof _!="number"||isNaN(_)))throw new Error("offset and limit must be numbers");let d=a?[a]:[],o=I().replace(/-/g,""),A=!1,v,w,S=async()=>{await E.transaction(async i=>{let n=g&&g.length>0?await O(E,e,g,i):e;await i.exec(`CREATE OR REPLACE TEMP VIEW live_query_${o}_view AS ${n}`);let u=await q(i,`live_query_${o}_view`);await F(i,u,p),t?(await i.exec(`
              PREPARE live_query_${o}_get(int, int) AS
              SELECT * FROM live_query_${o}_view
              LIMIT $1 OFFSET $2;
            `),await i.exec(`
              PREPARE live_query_${o}_get_total_count AS
              SELECT COUNT(*) FROM live_query_${o}_view;
            `),T=(await i.query(`EXECUTE live_query_${o}_get_total_count;`)).rows[0].count,v={...await i.query(`EXECUTE live_query_${o}_get(${_}, ${l});`),offset:l,limit:_,totalCount:T}):(await i.exec(`
              PREPARE live_query_${o}_get AS
              SELECT * FROM live_query_${o}_view;
            `),v=await i.query(`EXECUTE live_query_${o}_get;`)),w=await Promise.all(u.map(f=>i.listen(`"table_change__${f.schema_oid}__${f.table_oid}"`,async()=>{R()})))})};await S();let R=C(async({offset:i,limit:n}={})=>{if(!t&&(i!==void 0||n!==void 0))throw new Error("offset and limit cannot be provided for non-windowed queries");if(i&&(typeof i!="number"||isNaN(i))||n&&(typeof n!="number"||isNaN(n)))throw new Error("offset and limit must be numbers");l=i??l,_=n??_;let u=async(f=0)=>{if(d.length!==0){try{t?v={...await E.query(`EXECUTE live_query_${o}_get(${_}, ${l});`),offset:l,limit:_,totalCount:T}:v=await E.query(`EXECUTE live_query_${o}_get;`)}catch(c){let s=c.message;if(s.startsWith(`prepared statement "live_query_${o}`)&&s.endsWith("does not exist")){if(f>M)throw c;await S(),u(f+1)}else throw c}if(N(d,v),t){let c=(await E.query(`EXECUTE live_query_${o}_get_total_count;`)).rows[0].count;c!==T&&(T=c,R())}}};await u()}),h=i=>{if(A)throw new Error("Live query is no longer active and cannot be subscribed to");d.push(i)},r=async i=>{i?d=d.filter(n=>n!==n):d=[],d.length===0&&!A&&(A=!0,await E.transaction(async n=>{await Promise.all(w.map(u=>u(n))),await n.exec(`
              DROP VIEW IF EXISTS live_query_${o}_view;
              DEALLOCATE live_query_${o}_get;
            `)}))};return m?.aborted?await r():m?.addEventListener("abort",()=>{r()},{once:!0}),N(d,v),{initialResults:v,subscribe:h,unsubscribe:r,refresh:R}},async changes(e,g,a,m){let l;if(typeof e!="string"&&(l=e.signal,g=e.params,a=e.key,m=e.callback,e=e.query),!a)throw new Error("key is required for changes queries");let _=m?[m]:[],t=I().replace(/-/g,""),T=!1,d=1,o,A,v=async()=>{await E.transaction(async r=>{let i=await O(E,e,g,r);await r.query(`CREATE OR REPLACE TEMP VIEW live_query_${t}_view AS ${i}`);let n=await q(r,`live_query_${t}_view`);await F(r,n,p);let u=[...(await r.query(`
                SELECT column_name, data_type, udt_name
                FROM information_schema.columns 
                WHERE table_name = 'live_query_${t}_view'
              `)).rows,{column_name:"__after__",data_type:"integer"}];await r.exec(`
            CREATE TEMP TABLE live_query_${t}_state1 (LIKE live_query_${t}_view INCLUDING ALL);
            CREATE TEMP TABLE live_query_${t}_state2 (LIKE live_query_${t}_view INCLUDING ALL);
          `);for(let f of[1,2]){let c=f===1?2:1;await r.exec(`
              PREPARE live_query_${t}_diff${f} AS
              WITH
                prev AS (SELECT LAG("${a}") OVER () as __after__, * FROM live_query_${t}_state${c}),
                curr AS (SELECT LAG("${a}") OVER () as __after__, * FROM live_query_${t}_state${f}),
                data_diff AS (
                  -- INSERT operations: Include all columns
                  SELECT 
                    'INSERT' AS __op__,
                    ${u.map(({column_name:s})=>`curr."${s}" AS "${s}"`).join(`,
`)},
                    ARRAY[]::text[] AS __changed_columns__
                  FROM curr
                  LEFT JOIN prev ON curr.${a} = prev.${a}
                  WHERE prev.${a} IS NULL
                UNION ALL
                  -- DELETE operations: Include only the primary key
                  SELECT 
                    'DELETE' AS __op__,
                    ${u.map(({column_name:s,data_type:L,udt_name:b})=>s===a?`prev."${s}" AS "${s}"`:`NULL${L==="USER-DEFINED"?`::${b}`:""} AS "${s}"`).join(`,
`)},
                      ARRAY[]::text[] AS __changed_columns__
                  FROM prev
                  LEFT JOIN curr ON prev.${a} = curr.${a}
                  WHERE curr.${a} IS NULL
                UNION ALL
                  -- UPDATE operations: Include only changed columns
                  SELECT 
                    'UPDATE' AS __op__,
                    ${u.map(({column_name:s,data_type:L,udt_name:b})=>s===a?`curr."${s}" AS "${s}"`:`CASE 
                              WHEN curr."${s}" IS DISTINCT FROM prev."${s}" 
                              THEN curr."${s}"
                              ELSE NULL${L==="USER-DEFINED"?`::${b}`:""}
                              END AS "${s}"`).join(`,
`)},
                      ARRAY(SELECT unnest FROM unnest(ARRAY[${u.filter(({column_name:s})=>s!==a).map(({column_name:s})=>`CASE
                              WHEN curr."${s}" IS DISTINCT FROM prev."${s}" 
                              THEN '${s}' 
                              ELSE NULL 
                              END`).join(", ")}]) WHERE unnest IS NOT NULL) AS __changed_columns__
                  FROM curr
                  INNER JOIN prev ON curr.${a} = prev.${a}
                  WHERE NOT (curr IS NOT DISTINCT FROM prev)
                )
              SELECT * FROM data_diff;
            `)}A=await Promise.all(n.map(f=>r.listen(`"table_change__${f.schema_oid}__${f.table_oid}"`,async()=>{w()})))})};await v();let w=C(async()=>{if(_.length===0&&o)return;let r=!1;for(let i=0;i<5;i++)try{await E.transaction(async n=>{await n.exec(`
                INSERT INTO live_query_${t}_state${d} 
                  SELECT * FROM live_query_${t}_view;
              `),o=await n.query(`EXECUTE live_query_${t}_diff${d};`),d=d===1?2:1,await n.exec(`
                TRUNCATE live_query_${t}_state${d};
              `)});break}catch(n){if(n.message===`relation "live_query_${t}_state${d}" does not exist`){r=!0,await v();continue}else throw n}D(_,[...r?[{__op__:"RESET"}]:[],...o.rows])}),S=r=>{if(T)throw new Error("Live query is no longer active and cannot be subscribed to");_.push(r)},R=async r=>{r?_=_.filter(i=>i!==i):_=[],_.length===0&&!T&&(T=!0,await E.transaction(async i=>{await Promise.all(A.map(n=>n(i))),await i.exec(`
              DROP VIEW IF EXISTS live_query_${t}_view;
              DROP TABLE IF EXISTS live_query_${t}_state1;
              DROP TABLE IF EXISTS live_query_${t}_state2;
              DEALLOCATE live_query_${t}_diff1;
              DEALLOCATE live_query_${t}_diff2;
            `)}))};return l?.aborted?await R():l?.addEventListener("abort",()=>{R()},{once:!0}),await w(),{fields:o.fields.filter(r=>!["__after__","__op__","__changed_columns__"].includes(r.name)),initialChanges:o.rows,subscribe:S,unsubscribe:R,refresh:w}},async incrementalQuery(e,g,a,m){let l;if(typeof e!="string"&&(l=e.signal,g=e.params,a=e.key,m=e.callback,e=e.query),!a)throw new Error("key is required for incremental queries");let _=m?[m]:[],t=new Map,T=new Map,d=[],o=!0,{fields:A,unsubscribe:v,refresh:w}=await $.changes(e,g,a,h=>{for(let n of h){let{__op__:u,__changed_columns__:f,...c}=n;switch(u){case"RESET":t.clear(),T.clear();break;case"INSERT":t.set(c[a],c),T.set(c.__after__,c[a]);break;case"DELETE":{let s=t.get(c[a]);t.delete(c[a]),s.__after__!==null&&T.delete(s.__after__);break}case"UPDATE":{let s={...t.get(c[a])??{}};for(let L of f)s[L]=c[L],L==="__after__"&&T.set(c.__after__,c[a]);t.set(c[a],s);break}}}let r=[],i=null;for(let n=0;n<t.size;n++){let u=T.get(i),f=t.get(u);if(!f)break;let c={...f};delete c.__after__,r.push(c),i=u}d=r,o||N(_,{rows:r,fields:A})});o=!1,N(_,{rows:d,fields:A});let S=h=>{_.push(h)},R=async h=>{h?_=_.filter(r=>r!==r):_=[],_.length===0&&await v()};return l?.aborted?await R():l?.addEventListener("abort",()=>{R()},{once:!0}),{initialResults:{rows:d,fields:A},subscribe:S,unsubscribe:R,refresh:w}}};return{namespaceObj:$}},j={name:"Live Queries",setup:U};async function q(E,y){return(await E.query(`
      WITH RECURSIVE view_dependencies AS (
        -- Base case: Get the initial view's dependencies
        SELECT DISTINCT
          cl.relname AS dependent_name,
          n.nspname AS schema_name,
          cl.oid AS dependent_oid,
          n.oid AS schema_oid,
          cl.relkind = 'v' AS is_view
        FROM pg_rewrite r
        JOIN pg_depend d ON r.oid = d.objid
        JOIN pg_class cl ON d.refobjid = cl.oid
        JOIN pg_namespace n ON cl.relnamespace = n.oid
        WHERE
          r.ev_class = (
              SELECT oid FROM pg_class WHERE relname = $1 AND relkind = 'v'
          )
          AND d.deptype = 'n'

        UNION ALL

        -- Recursive case: Traverse dependencies for views
        SELECT DISTINCT
          cl.relname AS dependent_name,
          n.nspname AS schema_name,
          cl.oid AS dependent_oid,
          n.oid AS schema_oid,
          cl.relkind = 'v' AS is_view
        FROM view_dependencies vd
        JOIN pg_rewrite r ON vd.dependent_name = (
          SELECT relname FROM pg_class WHERE oid = r.ev_class AND relkind = 'v'
        )
        JOIN pg_depend d ON r.oid = d.objid
        JOIN pg_class cl ON d.refobjid = cl.oid
        JOIN pg_namespace n ON cl.relnamespace = n.oid
        WHERE d.deptype = 'n'
      )
      SELECT DISTINCT
        dependent_name AS table_name,
        schema_name,
        dependent_oid AS table_oid,
        schema_oid
      FROM view_dependencies
      WHERE NOT is_view; -- Exclude intermediate views
    `,[y])).rows.map($=>({table_name:$.table_name,schema_name:$.schema_name,table_oid:$.table_oid,schema_oid:$.schema_oid}))}async function F(E,y,p){let $=y.filter(e=>!p.has(`${e.schema_oid}_${e.table_oid}`)).map(e=>`
      CREATE OR REPLACE FUNCTION "_notify_${e.schema_oid}_${e.table_oid}"() RETURNS TRIGGER AS $$
      BEGIN
        PERFORM pg_notify('table_change__${e.schema_oid}__${e.table_oid}', '');
        RETURN NULL;
      END;
      $$ LANGUAGE plpgsql;
      CREATE OR REPLACE TRIGGER "_notify_trigger_${e.schema_oid}_${e.table_oid}"
      AFTER INSERT OR UPDATE OR DELETE ON "${e.schema_name}"."${e.table_name}"
      FOR EACH STATEMENT EXECUTE FUNCTION "_notify_${e.schema_oid}_${e.table_oid}"();
      `).join(`
`);$.trim()!==""&&await E.exec($),y.map(e=>p.add(`${e.schema_oid}_${e.table_oid}`))}var N=(E,y)=>{for(let p of E)p(y)},D=(E,y)=>{for(let p of E)p(y)};export{j as live};
//# sourceMappingURL=index.js.map