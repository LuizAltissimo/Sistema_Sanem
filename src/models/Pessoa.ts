import { Base } from './Base';

export class Pessoa extends Base {
    private nome: string;
    private cpf: string;
    private telefone: string;
    private email: string;
    private endereco: string;

    constructor(
        id: number = 0,
        nome: string = '',
        cpf: string = '',
        telefone: string = '',
        email: string = '',
        endereco: string = ''
    ) {
        super(id);
        this.nome = nome;
        this.cpf = cpf;
        this.telefone = telefone;
        this.email = email;
        this.endereco = endereco;
    }

    public getNome(): string {
        return this.nome;
    }

    public setNome(nome: string): void {
        this.nome = nome;
    }

    public getCpf(): string {
        return this.cpf;
    }

    public setCpf(cpf: string): void {
        this.cpf = cpf;
    }

    public getTelefone(): string {
        return this.telefone;
    }

    public setTelefone(telefone: string): void {
        this.telefone = telefone;
    }

    public getEmail(): string {
        return this.email;
    }

    public setEmail(email: string): void {
        this.email = email;
    }

    public getEndereco(): string {
        return this.endereco;
    }

    public setEndereco(endereco: string): void {
        this.endereco = endereco;
    }
} 