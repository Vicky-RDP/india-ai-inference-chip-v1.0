const githubUrl = 'https://github.com/Vicky-RDP/india-ai-inference-chip-v1.0';
const blueprintUrl = 'https://github.com/Vicky-RDP/india-ai-inference-chip-v1.0/blob/main/docs/project-blueprint.md';
const roadmapUrl = 'https://github.com/Vicky-RDP/india-ai-inference-chip-v1.0/blob/main/docs/tapeout-roadmap.md';

const principles = [
  { number: '01', title: 'Inference is where AI becomes real', copy: 'Every camera, robot, vehicle, device and service will need to run intelligence continuously, close to the world it is observing.' },
  { number: '02', title: 'Sovereignty means owning the stack', copy: 'A resilient AI economy needs more than models. It needs the silicon, software, tools and know-how to run them on its own terms.' },
  { number: '03', title: 'Open source is our speed strategy', copy: 'We are publishing the design so universities, startups, companies and independent engineers can build in parallel and improve it in public.' },
];

const stack = [
  ['01', 'Open RTL', 'Portable, reviewable SystemVerilog at the foundation.'],
  ['02', 'RISC-V host', 'An open control plane for firmware, drivers and tools.'],
  ['03', 'Inference core', 'INT8-first compute for efficient edge intelligence.'],
  ['04', 'Physical AI', 'A path from perception to action in the real world.'],
];

const blueprint = [
  ['01', 'Compute', 'Signed INT8 dot products, then tiled matrix operations.'],
  ['02', 'Control', 'RISC-V host, command queue, status and interrupts.'],
  ['03', 'Memory', 'DMA and scratchpad contracts built for reproducible workloads.'],
  ['04', 'Silicon', 'FPGA evidence first, then a small open ASIC submission.'],
];

const milestones = [
  ['G0', 'Arithmetic contract', 'Aug–Sep 2026'],
  ['G1', 'Streaming core', 'Sep–Oct 2026'],
  ['G2', 'Tile + memory', 'Oct–Nov 2026'],
  ['G3', 'FPGA proof', 'Jan–Feb 2027'],
  ['G4', 'ASIC hardening', 'Mar–Jun 2027'],
  ['G5', 'Tapeout window', 'Jul 2027'],
];

export default function Home() {
  return (
    <main>
      <div className="top-rule" />
      <nav className="nav shell" aria-label="Main navigation">
        <a className="wordmark" href="#top" aria-label="India AI Inference Chip v1.0 home">
          <span className="wordmark-mark"><img src="/iaic-mark.svg" alt="" /></span>
          <span className="wordmark-copy"><strong>India AI Inference Chip</strong><small>v1.0 · Open initiative</small></span>
        </a>
        <div className="nav-links">
          <a href="#why">Why sovereignty</a><a href="#plan">The plan</a><a href="#build">Build with us</a>
          <a className="nav-cta" href={githubUrl} target="_blank" rel="noreferrer">Open GitHub <span aria-hidden="true">↗</span></a>
        </div>
      </nav>

      <section className="hero shell" id="top">
        <div className="hero-copy">
          <div className="eyebrow"><span className="live-dot" /> Live now · Work has started</div>
          <h1>India needs its own <em>AI inference chip.</em></h1>
          <p className="hero-lede">India AI Inference Chip v1.0 is an open-source beginning for a sovereign AI stack — built in India, built with the world.</p>
          <div className="hero-actions"><a className="button button-primary" href={githubUrl} target="_blank" rel="noreferrer">Join the build <span aria-hidden="true">↗</span></a><a className="text-link" href="#why">Understand the mission <span aria-hidden="true">↓</span></a></div>
          <div className="hero-stats" aria-label="Project status"><div><strong>01</strong><span>Open beginning</span></div><div><strong>INT8</strong><span>Inference first</span></div><div><strong>∞</strong><span>Global contributors</span></div></div>
        </div>
        <div className="hero-art" aria-label="Concept render of an India AI inference chip connected to physical AI devices">
          <img src="/iaic-hero.png" alt="Concept render of an AI inference chip connecting a robot, vehicle, camera and sensor" />
          <div className="hero-art-label label-one"><span /> Perception</div><div className="hero-art-label label-two"><span /> Compute</div><div className="hero-art-label label-three"><span /> Action</div>
        </div>
      </section>

      <section className="signal-strip"><div className="shell signal-inner"><span>Make in India</span><i /><span>Open source by design</span><i /><span>GenAI + world models</span><i /><span>Built for everyone</span></div></section>

      <section className="blueprint section shell" id="blueprint">
        <div className="section-kicker">00 / The blueprint</div>
        <div className="blueprint-heading"><h2>Small first.<br /><span>Complete stack.</span></h2><div><p className="lead-copy">The first chip is intentionally narrow: a verifiable INT8 engine that can travel from simulation to FPGA to silicon.</p><a className="text-link dark-link" href={blueprintUrl} target="_blank" rel="noreferrer">Read the full blueprint <span aria-hidden="true">↗</span></a></div></div>
        <div className="blueprint-grid">{blueprint.map(([number, title, copy]) => <article className="blueprint-card" key={number}><span>{number}</span><h3>{title}</h3><p>{copy}</p></article>)}</div>
      </section>

      <section className="mission section shell" id="why">
        <div className="section-kicker">01 / The case for sovereignty</div>
        <div className="mission-grid"><h2>AI will be<br /><span>everywhere.</span></h2><div className="mission-copy"><p className="lead-copy">The next decade of AI will not be defined only by the biggest models in the biggest clouds. It will be defined by intelligence running everywhere — in hospitals, factories, farms, classrooms, transport, defence and homes.</p><p>Inference is the part of AI that meets the world. It turns a trained model into an action, a decision, a safer road, a more useful machine. If India does not own enough of that layer, it will depend on other countries for the intelligence inside its own infrastructure.</p><p>IAIC begins with a simple conviction: every country should be able to build a sovereign AI stack. India can contribute the silicon, the software and the open community that make that future possible.</p></div></div>
        <div className="principles-grid">{principles.map((item) => <article className="principle" key={item.number}><span className="principle-number">{item.number}</span><h3>{item.title}</h3><p>{item.copy}</p></article>)}</div>
      </section>

      <section className="physical section shell"><div className="physical-art"><img src="/physical-ai-board.png" alt="AI accelerator board with perception, reasoning and action data flows" /><div className="image-caption">A visual language for physical AI: sense → understand → act</div></div><div className="physical-copy"><div className="section-kicker">02 / Beyond the chatbot</div><h2>Not only<br /><span>GenAI.</span></h2><p className="lead-copy">The same inference layer that powers language and vision models will sit inside the machines that move through the physical world.</p><p>World models, robotics, autonomous systems, industrial inspection, medical devices, agricultural intelligence and edge vision all need fast, efficient and dependable inference — often where the cloud is too slow, too expensive or simply unavailable.</p><div className="use-cases"><span>Robotics</span><span>Autonomy</span><span>Industry</span><span>Healthcare</span><span>AgriTech</span><span>Defence</span></div></div></section>

      <section className="architecture section shell"><div className="architecture-intro"><div className="section-kicker">03 / IAIC v1.0</div><h2>The beginning<br />of the stack.</h2><p>IAIC v1.0 starts narrow on purpose: an open, verifiable INT8 inference core that can move from simulation to FPGA to silicon. Then the community expands the stack around it.</p><a className="text-link dark-link" href={githubUrl} target="_blank" rel="noreferrer">Read the technical roadmap <span aria-hidden="true">↗</span></a></div><div className="stack-grid">{stack.map(([number, title, copy]) => <article className="stack-card" key={number}><span>{number}</span><div><h3>{title}</h3><p>{copy}</p></div></article>)}</div></section>

      <section className="roadmap section shell" id="plan">
        <div className="section-kicker">03.5 / Under one year</div>
        <div className="roadmap-heading"><h2>A public path<br />to <span>tapeout.</span></h2><div><p className="lead-copy">The target is a first small test chip submission by 23 July 2027. Every gate has an artifact, an owner and a review.</p><a className="text-link dark-link" href={roadmapUrl} target="_blank" rel="noreferrer">Open the execution roadmap <span aria-hidden="true">↗</span></a></div></div>
        <div className="milestone-grid">{milestones.map(([gate, title, date]) => <article className="milestone" key={gate}><span>{gate}</span><h3>{title}</h3><p>{date}</p></article>)}</div>
      </section>

      <section className="open section shell" id="build"><div className="open-topline"><span>04 / The invitation</span><span>Apache-2.0 · Open by default</span></div><div className="open-grid"><h2>Build the full<br /><em>stack with us.</em></h2><div className="open-copy"><p className="lead-copy">Open source is how we move fast. Hardware engineers, verification specialists, RISC-V developers, compiler builders, AI researchers, FPGA makers, educators and storytellers can all contribute from day one.</p><p>You can join from Bengaluru, Hyderabad, Delhi, anywhere in India or anywhere in the world. Start with a test, a document, a benchmark, a design review or a new idea. The project is an open-source initiative of RDP, built in public with contributors worldwide.</p><div className="open-actions"><a className="button button-light" href={githubUrl} target="_blank" rel="noreferrer">Join on GitHub <span aria-hidden="true">↗</span></a><a className="text-link light-link" href="mailto:vicky@rdp.in">Contact the project steward <span aria-hidden="true">↗</span></a></div></div></div><div className="contributor-line"><span className="contributor-pulse" /> Developers · universities · startups · industry · public institutions · curious minds</div></section>

      <footer className="footer shell"><div className="footer-brand"><span className="wordmark-mark"><img src="/iaic-mark.svg" alt="" /></span><div><strong>India AI Inference Chip v1.0</strong><small>Open-source initiative of RDP · भारत से · दुनिया के लिए</small></div></div><div className="footer-links"><a href={githubUrl} target="_blank" rel="noreferrer">GitHub ↗</a><a href="https://www.rdp.in/" target="_blank" rel="noreferrer">RDP ↗</a><a href="mailto:vicky@rdp.in">vicky@rdp.in</a><span>Apache-2.0</span></div><div className="make-in-india"><span>Designed for a sovereign AI future</span><img src="/make-in-india.png" alt="Make in India lion logo" /></div></footer>
    </main>
  );
}
