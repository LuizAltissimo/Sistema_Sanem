export abstract class Base {
    protected id: number;

    constructor(id: number = 0) {
        this.id = id;
    }

    public getId(): number {
        return this.id;
    }

    public setId(id: number): void {
        this.id = id;
    }
} 