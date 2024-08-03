export const EditorComm = {
    mounted() {
        console.log(this.el);

        this.el.addEventListener("phx:content:updated", (event) => {
            this.pushEventTo(this.el.dataset.owner, "phx:content:updated", {
                changes: event.detail.changes
            });
        });

    },
    destoryed() {
        
    }
}