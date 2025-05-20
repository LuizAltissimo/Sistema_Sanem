import { Pessoa } from './Pessoa';

export class Voluntario extends Pessoa {
    private cargo: string;
    private dataAdmissao: Date;

    constructor(
        id: number = 0,
        nome: string = '',
        cpf: string = '',
        telefone: string = '',
        email: string = '',
        endereco: string = '',
        cargo: string = '',
        dataAdmissao: Date = new Date()
    ) {
        super(id, nome, cpf, telefone, email, endereco);
        this.cargo = cargo;
        this.dataAdmissao = dataAdmissao;
    }

    public getCargo(): string {
        return this.cargo;
    }

    public setCargo(cargo: string): void {
        this.cargo = cargo;
    }

    public getDataAdmissao(): Date {
        return this.dataAdmissao;
    }

    public setDataAdmissao(dataAdmissao: Date): void {
        this.dataAdmissao = dataAdmissao;
    }
} 