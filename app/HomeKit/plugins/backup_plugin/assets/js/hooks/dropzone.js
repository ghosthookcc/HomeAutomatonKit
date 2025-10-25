import JSZip from "jszip";

const Dropzone = 
{
    mounted() 
    {
        const dropzone = this.el; 
        const input = dropzone.querySelector("input[type='file']");

        dropzone.addEventListener("click", () => 
        {
            input.click();
        });

        input.setAttribute("webkitdirectory", "");
        input.setAttribute("multiple", "");

        input.addEventListener("change", async(e) => 
        {
            e.preventDefault();
            e.stopPropagation();

            const files = Array.from(e.target.files);
            const processedFiles = [];

            for (let file in files)
            {
                const relativePath = file.webkitRelativePath || file.name;
                const fileWithPath = new File([file], file.name, 
                {
                    type: file.type,
                    lastModified: file.lastModified
                });

                Object.defineProperty(fileWithPath, "webkitRelativePath", 
                {
                    value: relativePath,
                    writable: false
                });
                processedFiles.push(fileWithPath);
            }

            if (processedFiles.length > 0)
            {
                this.upload("uploader", processedFiles);
            }

            e.target.value = "";
        });

        dropzone.addEventListener("dragover", e => 
        {
            dropzone.classList.add("border-blue-400", "bg-blue-50");
        });

        dropzone.addEventListener("dragleave", e => 
        {
            dropzone.classList.remove("border-blue-400", "bg-blue-50");
        });

        dropzone.addEventListener("drop", async (e) => 
        {
            e.preventDefault();
            e.stopPropagation();

            dropzone.classList.remove("border-blue-400", "bg-blue-50");

            const items = e.dataTransfer.items;
            const allFiles = [];

            for (let idx = 0; idx < items.length; idx++)
            {
                const item = items[idx].webkitGetAsEntry();
                if (item)
                {
                    const result = await traverseFileTree(item);
                    if (Array.isArray(result))
                    {
                        allFiles.push(...result);
                    }
                    else if (result)
                    {
                        allFiles.push(result);
                    }
                }
            }

            const dataTransfer = new DataTransfer();
            allFiles.forEach(file => dataTransfer.items.add(file));

            input.files = dataTransfer.files;

            if (allFiles.length > 0)
            {
                this.upload("uploader", allFiles);
            }
        });

        async function traverseFileTree(item, path = "") 
        {
            if (item.isFile) 
            {
                console.log(item);
                return new Promise((resolve) => 
                {
                    item.file(file => 
                    {
                        const relativePath = path + file.name;
                        const fileWithPath = new File([file], file.name, 
                        {
                            type: file.type,
                            lastModified: file.lastModified
                        });
                        Object.defineProperty(fileWithPath, "webkitRelativePath", { value: path + file.name, writable: false });
                        resolve(fileWithPath);
                    });
                });
            }
            else if (item.isDirectory) 
            {
                const directoryReader = item.createReader();
                const entries = await new Promise((resolve) => 
                {
                    directoryReader.readEntries(resolve);
                });

                const files = [];
                for (let entry of entries)
                {
                    const result = await traverseFileTree(entry, path + item.name + "/");
                    if (Array.isArray(result))
                    {
                        files.push(...result);
                    }
                    else if (result)
                    {
                        files.push(result);
                    }
                }
                return files;
            }
            return null;
        }
    }
}

const DropzoneZipped = 
{
    mounted()
    {
        this.el.addEventListener("input", e => 
        {
            e.preventDefault();
            let zip = new JSZip();
            Array.from(e.target.files).forEach(file => 
            {
                zip.file(file.webkitRelativePath || file.name, file, {binary: true});
            });
            zip.generateAsync({type: "blob"}).then(blob => this.upload("uploader", [blob]));
        });
    }
}

const DropzoneHooks = 
{
    Dropzone,
    DropzoneZipped
};

export default DropzoneHooks;
