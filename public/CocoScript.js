class CocoScriptEngine {
    constructor() {
        this.env = {}; // variable storage
    }

    run(code) {
        // remove comments
        code = code.replace(/\/\/.*$/gm, '');
        // normalize whitespace
        const tokens = code.split('\n').map(l => l.trim()).filter(l => l.length);
        // join back for block parsing
        this.executeBlocks(tokens.join('\n'));
    }

    executeBlocks(code) {
        let i = 0;
        while (i < code.length) {
            if (code[i] === '?') {
                // collect the chain
                const chain = [];
                let condEnd = code.indexOf('{', i);
                let condition = code.slice(i + 1, condEnd).trim();
                let { block, endIndex } = this.extractBlock(code, condEnd);
                chain.push({ condition, block });
                i = endIndex + 1;

                // collect following not-blocks
                while (code.startsWith('else', i)) {
                    let condStart = i + 3;
                    let condEnd = code.indexOf('{', condStart);
                    let condition = code.slice(condStart, condEnd).trim();
                    if (condition.startsWith('?')) condition = condition.slice(1).trim();
                    let { block, endIndex } = this.extractBlock(code, condEnd);
                    chain.push({ condition: condition || null, block });
                    i = endIndex + 1;
                }

                // evaluate chain
                let executed = false;
                for (let branch of chain) {
                    if (executed) break;
                    if (branch.condition) {
                        if (this.evalValue(branch.condition)) {
                            this.run(branch.block);
                            executed = true;
                        }
                    } else {
                        // plain else
                        this.run(branch.block);
                        executed = true;
                    }
                }

                // IMPORTANT: continue to next iteration, don’t re‑parse the chain
                continue;
            } else {
                // normal line
                const nextLine = code.indexOf('\n', i);
                const line = code.slice(i, nextLine === -1 ? code.length : nextLine).trim();
                if (line) this.execute(line);
                i = nextLine === -1 ? code.length : nextLine + 1;
            }
        }
    }

    execute(line) {
        if (line.startsWith('style')) {
            const match = line.match(/style\(([^,]+),([^,]+),([^)]+)\)/);
            if (match) {
                const selector = match[1].trim().replace(/['"]/g, "");
                const property = match[2].trim().replace(/['"]/g, "");
                const value = match[3].trim().replace(/['"]/g, "");
                this.style(selector, property, value);
            }
        }
        else if (line.startsWith('!')) {
            const parts = line.replace(';', '').split(/\s*=\s*/);
            if (parts.length === 2) {
                const name = parts[0].slice(1);
                const value = parts[1];
                this.env[name] = this.evalValue(value);
            }
        }
        else if (/^\w+\s*=/.test(line)) {
            const parts = line.replace(';', '').split(/\s*=\s*/);
            if (parts.length === 2) {
                const name = parts[0];
                const value = parts[1];
                this.env[name] = this.evalValue(value);
            }
        }
        else if (line.startsWith('diplay')) {
            const match = line.match(/\((.*)\)/);
            if (match) {
                const inside = match[1];
                const val = this.evalValue(inside);
                console.log(val);

                const output = window.document.getElementById("CocoScript's-special-output");
                if (output) {
                    output.innerHTML =
                        `<li class="CocoScript's-special-output-item">${val}</li>` + output.innerHTML;
                }
            }
        }
    }

    evalValue(val) {
        if (val === undefined || val === null) return undefined;
        val = val.trim();

        if (val === 'true') return true;
        if (val === 'false') return false;
        if (!isNaN(val)) return Number(val);
        if (val.startsWith('"') && val.endsWith('"')) return val.slice(1, -1);

        // Handle logical AND
        if (val.includes('&&')) {
            const parts = val.split('&&').map(s => s.trim());
            return parts.every(expr => this.evalValue(expr));
        }

        // Handle logical OR
        if (val.includes('||')) {
            const parts = val.split('||').map(s => s.trim());
            return parts.some(expr => this.evalValue(expr));
        }

        // Handle comparisons
        if (val.includes('==')) {
            const [left, right] = val.split('==').map(s => s.trim());
            return this.evalValue(left) == this.evalValue(right);
        }
        if (val.includes('!=')) {
            const [left, right] = val.split('!=').map(s => s.trim());
            return this.evalValue(left) != this.evalValue(right);
        }
        if (val.includes('>')) {
            const [left, right] = val.split('>').map(s => s.trim());
            return this.evalValue(left) > this.evalValue(right);
        }
        if (val.includes('<')) {
            const [left, right] = val.split('<').map(s => s.trim());
            return this.evalValue(left) < this.evalValue(right);
        }

        // variable lookup
        return this.env[val];
    }

    extractBlock(code, startIndex) {
        let depth = 0;
        let block = '';
        for (let i = startIndex; i < code.length; i++) {
            const ch = code[i];
            if (ch === '{') {
                depth++;
                if (depth > 1) block += ch;
            } else if (ch === '}') {
                depth--;
                if (depth === 0) return { block: block.trim(), endIndex: i };
                else block += ch;
            } else {
                if (depth > 0) block += ch;
            }
        }
        return null; // unmatched braces
    }

    style(selector, property, value) {
        let styleTag = document.getElementById("coco-style");
        if (!styleTag) {
            styleTag = document.createElement("style");
            styleTag.id = "coco-style";
            document.head.appendChild(styleTag);
        }

        if (property === "background-img") {
            styleTag.textContent += `${selector} { background-image: url("${value}") !important; }\n`;
        } else {
            styleTag.textContent += `${selector} { ${property}: ${value} !important; }\n`;
        }
    }


}

const CocoScript = new CocoScriptEngine();
CocoScript.run(`
    diplay("CocoScript Activated!");
    !bg = "white";
    !font = "Arial";

    !isMe = username == "Nino";
    ?isMe {
        diplay("Hi me.");
    }
`);