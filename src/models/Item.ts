import { Base } from './Base';

export class Item extends Base {
    private tipo: string;
    private descricao: string;
    private tamanho: string;
    private condicao: string;
    private categoria: string;
    private status: string;

    constructor(
        id: number = 0,
        tipo: string = '',
        descricao: string = '',
        tamanho: string = '',
        condicao: string = '',
        categoria: string = '',
        status: string = 'DISPONIVEL'
    ) {
        super(id);
        this.tipo = tipo;
        this.descricao = descricao;
        this.tamanho = tamanho;
        this.condicao = condicao;
        this.categoria = categoria;
        this.status = status;
    }

    public getTipo(): string {
        return this.tipo;
    }

    public setTipo(tipo: string): void {
        this.tipo = tipo;
    }

    public getDescricao(): string {
        return this.descricao;
    }

    public setDescricao(descricao: string): void {
        this.descricao = descricao;
    }

    public getTamanho(): string {
        return this.tamanho;
    }

    public setTamanho(tamanho: string): void {
        this.tamanho = tamanho;
    }

    public getCondicao(): string {
        return this.condicao;
    }

    public setCondicao(condicao: string): void {
        this.condicao = condicao;
    }

    public getCategoria(): string {
        return this.categoria;
    }

    public setCategoria(categoria: string): void {
        this.categoria = categoria;
    }

    public getStatus(): string {
        return this.status;
    }

    public setStatus(status: string): void {
        this.status = status;
    }
} 