<template>
  <main class="page">
    <header class="hero">
      <h1>OpenClaw</h1>
      <p class="subtitle">一个把「工具」和「对话」连接起来的个人助理框架</p>
      <div class="badges">
        <span class="badge">Gateway</span>
        <span class="badge">Skills</span>
        <span class="badge">Channels</span>
        <span class="badge">Memory</span>
      </div>
    </header>

    <section class="card">
      <h2>它能做什么？</h2>
      <ul>
        <li>把聊天渠道（QQ/Telegram/…）接入同一个助理实例</li>
        <li>用“技能”把命令行、网页、文件、API 变成可调用的工具</li>
        <li>有工作区与记忆文件，便于持续迭代/自动化</li>
      </ul>
    </section>

    <section class="card">
      <h2>这页从哪来？</h2>
      <p>
        这是一个示例的 Vue + Node.js 应用：前端用 Vite 构建，后端用 Express 提供静态资源和简单 API。
        你可以在 Jenkins 上跑 CI/CD，把它发布到你的服务器。
      </p>
      <p class="muted">接口示例：<code>/api/health</code>、<code>/api/info</code></p>
    </section>

    <footer class="footer">
      <span>© {{ new Date().getFullYear() }} OpenClaw Demo</span>
    </footer>
  </main>
</template>

<style scoped>
.page {
  font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial;
  max-width: 960px;
  margin: 0 auto;
  padding: 28px 18px 40px;
  color: #111827;
}
.hero {
  padding: 22px 18px;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  background: linear-gradient(180deg, #f9fafb, #ffffff);
}
.subtitle { color: #4b5563; margin-top: 10px; }
.badges { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 14px; }
.badge {
  font-size: 12px;
  padding: 4px 10px;
  border-radius: 999px;
  border: 1px solid #e5e7eb;
  background: #fff;
}
.card {
  margin-top: 14px;
  padding: 18px;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  background: #ffffff;
}
.muted { color: #6b7280; }
.footer {
  margin-top: 18px;
  color: #6b7280;
  font-size: 12px;
}
code { background: #f3f4f6; padding: 2px 6px; border-radius: 6px; }
</style>
