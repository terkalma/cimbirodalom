const getHandlers = () => [
    document.getElementById("author-center-handler"),
    document.getElementById("author-edge-handler"),
];

const handlerWidth = 16;

const initPositions = (container) => {
    const [center, edge] = getHandlers();
    const centerX = (container.width - handlerWidth) / 2;
    const centerY = (container.height - handlerWidth) / 2;

    distance = container.width / 6;

    const edgeX = (centerX - distance) / Math.sqrt(2);
    const edgeY = (centerY - distance) / Math.sqrt(2);

    center.style.left = `${centerX}px`;
    center.style.top = `${centerY}px`;
    edge.style.left = `${edgeX}px`;
    edge.style.top = `${edgeY}px`;
};

const attachListeners = (handlerElem, { mouseup, mousemove }) => {
    const pos = { x: 0, y: 0 };

    const onMouseDown = (event) => {
        event.preventDefault();
        pos.x = event.clientX;
        pos.y = event.clientY;
        document.onmouseup = onDragEnd;
        document.onmousemove = onDrag;
    };

    const onDrag = (event) => {
        event.preventDefault();

        const deltaX = pos.x - event.clientX;
        const deltaY = pos.y - event.clientY;

        mousemove(deltaX, deltaY);
        pos.x = event.clientX;
        pos.y = event.clientY;
    };

    const onDragEnd = () => {
        document.onmouseup = null;
        document.onmousemove = null;
        mouseup();
    };

    handlerElem.onmousedown = onMouseDown;
};

const getNormalizedEdges = (container) => {
    const [center, edge] = getHandlers();
    const getOffset = (element) => [
        element.offsetLeft + handlerWidth / 2,
        element.offsetTop + handlerWidth / 2,
    ];

    const [cX, cY] = getOffset(center);
    const [eX, eY] = getOffset(edge);

    const xOffset = Math.abs(eX - cX);
    const yOffset = Math.abs(eY - cY);
    return {
        x1: (cX - xOffset) / container.width,
        y1: (cY - yOffset) / container.height,
        x2: (cX + xOffset) / container.width,
        y2: (cY + yOffset) / container.height,
    };
};

const authorImageCropper = (elem, cb) => {
    const container = {
        width: elem.offsetWidth,
        height: elem.offsetHeight,
    };

    const [center, edge] = getHandlers();

    center.onmousedown = null;
    edge.onmousedown = null;
    document.onmouseup = null;
    document.onmousemove = null;

    initPositions(container);

    attachListeners(center, {
        mousemove: (deltaX, deltaY) => {
            const [center, edge] = getHandlers();
            updatePosition(edge, deltaX, deltaY);
            updatePosition(center, deltaX, deltaY);
            updateClipPath();
        },
        mouseup: () => {
            cb(getNormalizedEdges(container));
        },
    });

    attachListeners(edge, {
        mousemove: (deltaX, deltaY) => {
            const [_, edge] = getHandlers();
            updatePosition(edge, deltaX, deltaY);
            updateClipPath();
        },
        mouseup: () => {            
            cb(getNormalizedEdges(container));
        },
    });

    const updateClipPath = () => {
        const [center, edge] = getHandlers();
        const getOffset = (element) => [
            element.offsetLeft + handlerWidth / 2,
            element.offsetTop + handlerWidth / 2,
        ];

        const [cX, cY] = getOffset(center);
        const [eX, eY] = getOffset(edge);

        const distance = Math.sqrt(Math.pow(eX - cX, 2) + Math.pow(eY - cY, 2));
        const centerX = (cX / container.width) * 100;
        const centerY = (cY / container.height) * 100;

        const image = elem.querySelectorAll("img")[0];
        image.style["clip-path"] = `circle(${Math.round(
            distance
        )}px at ${Math.round(centerX)}% ${Math.round(centerY)}%)`;
    };

    const updatePosition = (handler, deltaX, deltaY) => {
        const x = Math.min(
            Math.max(0, handler.offsetLeft - deltaX),
            container.width - handlerWidth
        );

        const y = Math.min(
            Math.max(0, handler.offsetTop - deltaY),
            container.height - handlerWidth
        );

        handler.style.left = `${x}px`;
        handler.style.top = `${y}px`;
    };

    updateClipPath();
    cb(getNormalizedEdges(container));
};

export const AuthorImageHook = {
    mounted() {
        this.resizeObserver = new ResizeObserver(() => {
            this.el.offsetHeight > 0 &&
                authorImageCropper(this.el, (data) => {
                    const elem = document.getElementById("author_image_data");
                    console.log(data)
                    console.log(this.el)
                    elem.value = JSON.stringify(data);
                });
        });

        this.resizeObserver.observe(this.el);
    },
    destroyed() {
        this.resizeObserver &&
            (console.log("Disconnecting resize observer"),
            this.resizeObserver.disconnect());
    },
};
