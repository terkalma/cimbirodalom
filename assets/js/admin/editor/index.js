import Quill from "quill";
import { Delta } from "quill/core";


const initEditor = (elId) => {
    
    const editor = new Quill(`#${elId}`, {
        bounds: `#${elId}`,
        theme: "bubble"
    });

    const el = document.getElementById(elId);
    const { contents, version } = JSON.parse(el.dataset.document);
    editor.setContents(contents),
    editor.history.clear();

    let changes = new Delta();
    editor.on("text-change", function(delta, oldDelta, source) {
        if (source === "user") {            
            console.log("A user action triggered this change", delta);
            changes = changes.compose(delta);
        }
    });

    setInterval(() => {
        if (changes.ops.length > 0) {
            console.log("Sending changes to the server");

            const hookProxy = document.getElementById(`${elId}-comm`);

            if (hookProxy) {
                hookProxy.dispatchEvent(new CustomEvent("phx:content:updated", {
                    detail: {
                        changes: changes
                    }
                }));
            } else {
                console.error("Could not find the editor comm hook: ", `#${elId}-comm`);
            }
            
            changes = new Delta();
        }
    }, 1000)

}


export { initEditor };