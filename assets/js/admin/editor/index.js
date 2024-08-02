import Quill from "quill";


const initEditor = (elId) => {
    
    const editor = new Quill(`#${elId}`, {
        bounds: `#${elId}`,
        theme: "bubble"
    });


    editor.on("text-change", function(delta, oldDelta, source) {
        if (source === "user") {
            console.log("A user action triggered this change", delta);
        }
    });

}


export { initEditor };