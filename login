<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartDescAi | Marketing Digital & Eco</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;700;800&family=DM+Sans:ital,wght@0,300;0,400;1,300&display=swap" rel="stylesheet">
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>

    <style>
        :root {
            --bg: #05050a; --card: #0e0e18; --accent: #ff4d00; --accent2: #ffb800;
            --green: #22c55e; --text: #f0ede8; --muted: #6b6880; --border: rgba(255,255,255,0.07);
        }
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        body{background:var(--bg);color:var(--text);font-family:'DM Sans',sans-serif;font-weight:300;overflow-x:hidden}
        
        /* Cursor & UI Elements */
        .cursor{width:12px;height:12px;background:var(--accent);border-radius:50%;position:fixed;pointer-events:none;z-index:9999;transform:translate(-50%,-50%)}
        .cursor-ring{width:36px;height:36px;border:1px solid rgba(255,77,0,0.5);border-radius:50%;position:fixed;pointer-events:none;z-index:9998;transition:transform 0.35s ease;transform:translate(-50%,-50%)}
        
        nav{position:sticky;top:0;z-index:100;display:flex;align-items:center;justify-content:space-between;padding:1.2rem 5%;backdrop-filter:blur(12px);background:rgba(5,5,10,0.85);border-bottom:1px solid var(--border)}
        .logo{font-family:'Syne',sans-serif;font-weight:800;font-size:1.4rem;letter-spacing:-0.03em}
        .logo span{color:var(--accent)}
        
        /* Seção de Autenticação Customizada */
        .auth-section{padding:7rem 5%; background: var(--bg)}
        .auth-grid{display:grid;grid-template-columns:1fr 1fr;gap:2.5rem;max-width:1000px;margin:4rem auto}
        .auth-card{background:var(--card);border:1px solid var(--border);padding:2.5rem;border-radius:8px;transition: transform 0.3s}
        .auth-card:hover{transform: translateY(-5px)}
        .auth-card.highlighted{border-top: 3px solid var(--accent)}
        .auth-card h3{font-family:'Syne',sans-serif;font-size:1.8rem;margin-bottom:0.5rem}
        .auth-sub{color:var(--muted);font-size:0.9rem;margin-bottom:2rem}
        
        .field{display:flex;flex-direction:column;gap:0.5rem;margin-bottom:1.2rem}
        .field label{font-size:0.75rem;text-transform:uppercase;letter-spacing:0.1em;color:var(--muted)}
        .field input{background:rgba(255,255,255,0.03);border:1px solid var(--border);padding:0.9rem;color:#fff;border-radius:4px;outline:none}
        .field input:focus{border-color:var(--accent)}
        
        .btn-auth{width:100%;padding:1rem;border:none;border-radius:4px;font-family:'Syne',sans-serif;font-weight:700;cursor:pointer;transition:0.3s}
        .btn-login{background:var(--accent);color:#fff}
        .btn-reg{background:transparent;border:1px solid var(--border);color:#fff}
        .btn-auth:hover{opacity:0.8;transform:scale(1.02)}

        /* Toast Notification */
        .toast{position:fixed;bottom:2rem;right:2rem;padding:1rem 2rem;border-radius:4px;color:#000;font-weight:bold;z-index:10000;transform:translateY(150%);transition:0.4s}
        .toast.show{transform:translateY(0)}
        .toast.success{background:var(--green)}
        .toast.error{background:#ff4444; color:#fff}

        @media(max-width:768px){ .auth-grid{grid-template-columns:1fr} }
    </style>
</head>
<body>

<div class="cursor" id="cursor"></div>
<div class="cursor-ring" id="cursorRing"></div>
<div id="toast" class="toast"></div>

<nav>
    <div class="logo">Smart<span>DescAi</span></div>
</nav>

<section id="auth" class="auth-section">
    <div style="text-align:center">
        <h2 style="font-family:'Syne'; font-size:3rem">Área do Cliente</h2>
        <p style="color:var(--muted)">Gerencie suas campanhas e veja seu impacto ambiental</p>
    </div>

    <div class="auth-grid">
        <div class="auth-card highlighted">
            <h3>Entrar</h3>
            <p class="auth-sub">Acesse seu dashboard de resultados.</p>
            <form id="loginForm">
                <div class="field">
                    <label>E-mail</label>
                    <input type="email" id="loginEmail" placeholder="seu@email.com" required>
                </div>
                <div class="field">
                    <label>Senha</label>
                    <input type="password" id="loginPassword" placeholder="••••••••" required>
                </div>
                <button type="submit" class="btn-auth btn-login">ACESSAR PAINEL</button>
            </form>
        </div>

        <div class="auth-card">
            <h3>Cadastrar</h3>
            <p class="auth-sub">Crie sua conta e comece a crescer.</p>
            <form id="registerForm">
                <div class="field">
                    <label>Nome Completo</label>
                    <input type="text" id="regName" placeholder="Como quer ser chamado?" required>
                </div>
                <div class="field">
                    <label>E-mail Corporativo</label>
                    <input type="email" id="regEmail" placeholder="seu@email.com" required>
                </div>
                <div class="field">
                    <label>Senha</label>
                    <input type="password" id="regPassword" placeholder="Mínimo 6 caracteres" required>
                </div>
                <button type="submit" class="btn-auth btn-reg">CRIAR CONTA</button>
            </form>
        </div>
    </div>
</section>

<script>
    // 1. CONFIGURAÇÃO SUPABASE (MUDE APENAS AQUI)
    const SUPABASE_URL = 'SEU_URL_AQUI'; 
    const SUPABASE_ANON_KEY = 'SUA_CHAVE_ANON_AQUI';
    
    const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    // 2. LÓGICA DE CADASTRO
    document.getElementById('registerForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('regEmail').value;
        const password = document.getElementById('regPassword').value;
        const name = document.getElementById('regName').value;

        const { data, error } = await supabase.auth.signUp({
            email,
            password,
            options: { data: { full_name: name } }
        });

        if (error) {
            showNotify(error.message, 'error');
        } else {
            showNotify("Sucesso! Verifique seu e-mail para confirmar.", 'success');
            e.target.reset();
        }
    });

    // 3. LÓGICA DE LOGIN
    document.getElementById('loginForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('loginEmail').value;
        const password = document.getElementById('loginPassword').value;

        const { data, error } = await supabase.auth.signInWithPassword({ email, password });

        if (error) {
            showNotify(error.message, 'error');
        } else {
            showNotify("Login realizado com sucesso!", 'success');
            // Redireciona após 1.5s (ex: para dashboard.html)
            setTimeout(() => { window.location.href = '#'; }, 1500);
        }
    });

    // Utilitários de Interface (Toast & Cursor)
    function showNotify(msg, type) {
        const t = document.getElementById('toast');
        t.textContent = msg;
        t.className = `toast show ${type}`;
        setTimeout(() => t.classList.remove('show'), 4000);
    }

    const cursor=document.getElementById('cursor'), ring=document.getElementById('cursorRing');
    let mx=0,my=0,rx=0,ry=0;
    document.addEventListener('mousemove',e=>{mx=e.clientX;my=e.clientY});
    (function anim(){
        rx+=(mx-rx)*0.12; ry+=(my-ry)*0.12;
        cursor.style.left=mx+'px'; cursor.style.top=my+'px';
        ring.style.left=rx+'px'; ring.style.top=ry+'px';
        requestAnimationFrame(anim)
    })();
</script>

</body>
</html>
